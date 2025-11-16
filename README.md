# dotfiles

WSL用のプロキシ環境対応dotfile管理リポジトリ

## 概要

このリポジトリは、WSL (Windows Subsystem for Linux) のプロキシ環境において、以下のツールの設定を管理します：

- **Git** - バージョン管理
- **Docker** - コンテナ管理
- **Golang** - Go言語開発環境
- **Helm** - Kubernetesパッケージ管理
- **Google Cloud SDK** - GCPツールとSSH設定
- **SSH** - セキュアシェル接続
- **Ansible** - 構成管理

デプロイタイプ（edge、cloud、onprem、all）に応じて、適用される設定を分離できます。

## デプロイタイプ

| タイプ | 説明 | 有効な機能 |
|--------|------|------------|
| `all` (デフォルト) | すべての機能を有効化 | git, docker, golang, helm, gcloud, ssh, ansible |
| `edge` | エッジデバイス向け | git, docker, golang, ssh |
| `cloud` | クラウド環境向け | git, docker, golang, helm, gcloud, ssh |
| `onprem` | オンプレミス環境向け | git, ssh, ansible |

## セットアップ方法

### 1. chezmoiのインストール

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

### 2. 環境変数の設定

```bash
# デプロイタイプを設定（all, edge, cloud, onpremから選択）
export DEPLOYMENT_TYPE=all

# プロキシ設定（必要な場合）
export PROXY_HOST=proxy.example.com
export PROXY_PORT=8080
export NO_PROXY=localhost,127.0.0.1,.local

# Git設定
export GIT_USER_NAME="Your Name"
export GIT_USER_EMAIL="your.email@example.com"
```

### 3. dotfilesの適用

```bash
# リポジトリからdotfilesを取得して適用
chezmoi init --apply https://github.com/hiroyoshii/dotfiles.git
```

### 4. 設定の確認

```bash
# 適用されたファイルを確認
chezmoi managed

# 差分を確認
chezmoi diff
```

## cloud-initでの利用

cloud-initを使用して自動的にdotfilesを適用することができます。

1. `cloud-init.yaml`ファイルを編集して環境変数をカスタマイズ
2. クラウドインスタンス作成時にcloud-init設定として指定

```bash
# AWS EC2の例
aws ec2 run-instances \
  --image-id ami-xxxxx \
  --instance-type t2.micro \
  --user-data file://cloud-init.yaml
```

## 各ツールの設定詳細

### Git設定 (`.gitconfig`)
- プロキシ設定（HTTP/HTTPS）
- 基本的なエイリアス
- カラー出力
- 認証情報キャッシュ

### Docker設定 (`.docker/config.json`)
- Docker CLIプロキシ設定
- BuildKit有効化
- 認証ストア設定

### Go設定 (`.goproxy`)
- GOPROXYの設定
- プロキシ環境変数
- モジュールプライベート設定

### Helm設定 (`.helmrc`)
- Helmプロキシ環境変数
- キャッシュ・設定ディレクトリ

### SSH設定 (`.ssh/config`)
- プロキシコマンド設定
- GitHub/GitLab接続設定
- Google Cloud Compute設定
- 接続維持設定

### Ansible設定 (`.ansible.cfg`)
- インベントリ設定
- プロキシ環境変数
- SSH接続最適化

### Bash設定 (`.bashrc`)
- プロキシ環境変数の読み込み
- 各ツール設定の読み込み
- デプロイタイプ表示
- WSL固有設定

## プロキシ設定のカスタマイズ

プロキシを使用しない場合は、環境変数を空にします：

```bash
export PROXY_HOST=
```

プロキシ設定を変更する場合は、環境変数を再設定してchezmoiを再適用：

```bash
export PROXY_HOST=new-proxy.example.com
export PROXY_PORT=3128
chezmoi apply
```

## デプロイタイプの変更

```bash
# エッジデバイス向け設定に変更
export DEPLOYMENT_TYPE=edge
chezmoi apply

# クラウド環境向け設定に変更
export DEPLOYMENT_TYPE=cloud
chezmoi apply
```

## トラブルシューティング

### 設定が適用されない場合

```bash
# chezmoiのステータス確認
chezmoi doctor

# 強制的に再適用
chezmoi apply --force
```

### プロキシ設定の確認

```bash
# 環境変数を確認
env | grep -i proxy

# Git設定を確認
git config --get http.proxy
```

### Docker設定の確認

```bash
# Docker設定ファイルを確認
cat ~/.docker/config.json
```

## ライセンス

MIT

## 貢献

Issue、Pull Requestを歓迎します。