# Testing Guide

このドキュメントは、dotfilesの設定をテストするためのガイドです。

## ローカルテスト

### 1. 前提条件

- Linux環境（WSL、Ubuntu、Debian等）
- `curl`がインストールされていること

### 2. chezmoiのインストール

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 3. 環境変数の設定

各デプロイメントタイプに応じた環境変数を設定します。

#### allデプロイメント（すべての機能）

```bash
source examples/env.all.example
```

#### edgeデプロイメント（エッジデバイス）

```bash
source examples/env.edge.example
```

#### cloudデプロイメント（クラウド環境）

```bash
source examples/env.cloud.example
```

#### onpremデプロイメント（オンプレミス）

```bash
source examples/env.onprem.example
```

### 4. ドライラン（適用せずに確認）

```bash
# 何がインストールされるか確認
chezmoi init --dry-run https://github.com/hiroyoshii/dotfiles.git

# 差分を確認
chezmoi diff
```

### 5. 実際の適用

```bash
# dotfilesを適用
chezmoi init --apply https://github.com/hiroyoshii/dotfiles.git

# 適用されたファイルを確認
chezmoi managed
```

### 6. 設定の検証

#### Git設定の確認

```bash
cat ~/.gitconfig
git config --get http.proxy
```

#### Docker設定の確認

```bash
cat ~/.docker/config.json
```

#### プロキシ環境変数の確認

```bash
source ~/.bashrc
env | grep -i proxy
```

#### SSH設定の確認

```bash
cat ~/.ssh/config
```

#### Ansible設定の確認（onpremのみ）

```bash
cat ~/.ansible.cfg
```

## デプロイメントタイプ別のテスト

### allデプロイメント

全ての設定ファイルが適用されることを確認：

```bash
export DEPLOYMENT_TYPE=all
ls -la ~ | grep -E '\.(gitconfig|docker|goproxy|helmrc|ansible.cfg)'
ls -la ~/.ssh/config
```

### edgeデプロイメント

Docker、Go、SSH設定のみが適用されることを確認：

```bash
export DEPLOYMENT_TYPE=edge
# Helmとansibleは適用されないはず
! test -f ~/.helmrc && ! test -f ~/.ansible.cfg
# Gitとdockerは適用されるはず
test -f ~/.gitconfig && test -f ~/.docker/config.json
```

### cloudデプロイメント

Helm、gcloud設定が適用されることを確認：

```bash
export DEPLOYMENT_TYPE=cloud
test -f ~/.helmrc && test -f ~/.gitconfig
```

### onpremデプロイメント

Ansible設定が適用されることを確認：

```bash
export DEPLOYMENT_TYPE=onprem
test -f ~/.ansible.cfg && test -f ~/.gitconfig
```

## プロキシ設定のテスト

### プロキシありの場合

```bash
export PROXY_HOST=proxy.example.com
export PROXY_PORT=8080
chezmoi apply

# プロキシ設定が反映されているか確認
cat ~/.gitconfig | grep proxy
cat ~/.docker/config.json | grep Proxy
source ~/.proxy_env && env | grep -i proxy
```

### プロキシなしの場合

```bash
export PROXY_HOST=
chezmoi apply

# プロキシ設定が含まれていないことを確認
! grep -i proxy ~/.gitconfig
```

## cloud-initのテスト

### ローカルでのcloud-init検証

cloud-initをローカル環境でテストするには：

```bash
# cloud-init構文チェック
cloud-init schema -c cloud-init.yaml

# または、dockerで検証
docker run --rm -v $(pwd)/cloud-init.yaml:/cloud-init.yaml \
  ubuntu:22.04 bash -c "
    apt-get update && apt-get install -y cloud-init && \
    cloud-init schema -c /cloud-init.yaml
  "
```

## トラブルシューティング

### chezmoiのデバッグモード

```bash
chezmoi apply --debug --verbose
```

### 設定のリセット

```bash
# chezmoiの状態をリセット
rm -rf ~/.local/share/chezmoi

# dotfilesを削除（注意：バックアップを取ってから）
chezmoi managed | xargs rm -f
```

### テンプレート変数の確認

```bash
# chezmoiが認識している変数を表示
chezmoi data
```

## CI/CDでのテスト

GitHub Actionsでのテスト例：

```yaml
name: Test dotfiles

on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    strategy:
      matrix:
        deployment_type: [all, edge, cloud, onprem]
    steps:
      - uses: actions/checkout@v3
      
      - name: Install chezmoi
        run: sh -c "$(curl -fsLS get.chezmoi.io)"
      
      - name: Test deployment type ${{ matrix.deployment_type }}
        env:
          DEPLOYMENT_TYPE: ${{ matrix.deployment_type }}
          PROXY_HOST: ""
          GIT_USER_NAME: "Test User"
          GIT_USER_EMAIL: "test@example.com"
        run: |
          chezmoi init --dry-run .
          chezmoi apply --dry-run
```

## 期待される動作

各デプロイメントタイプで適用されるファイル：

| ファイル | all | edge | cloud | onprem |
|---------|-----|------|-------|--------|
| .gitconfig | ✓ | ✓ | ✓ | ✓ |
| .docker/ | ✓ | ✓ | ✓ | ✗ |
| .goproxy | ✓ | ✓ | ✓ | ✗ |
| .helmrc | ✓ | ✗ | ✓ | ✗ |
| .ssh/config | ✓ | ✓ | ✓ | ✓ |
| .ansible.cfg | ✓ | ✗ | ✗ | ✓ |
| .proxy_env | ✓ | ✓ | ✓ | ✓ |
| .bashrc | ✓ | ✓ | ✓ | ✓ |
