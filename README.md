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
- **外部ツール管理** - apt管理外のバイナリとシステム設定（kubectl, terraform, yq等）

デプロイタイプ（edge、cloud、onprem、all）に応じて、適用される設定を分離できます。

### 外部ファイル管理

このリポジトリは、home/etcのようなディレクトリ構成で外部ファイルを管理し、apt管理外のコマンドのインストールもchezmoiで実施します。詳細は [EXTERNAL_TOOLS.md](EXTERNAL_TOOLS.md) を参照してください。

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

# 外部ツール（kubectl, terraform等）も自動的にインストールされます
```

### 4. システム設定のインストール（オプション）

```bash
# システムレベルの設定（/etc配下）をインストール（sudo必要）
sudo bash ~/.local/share/chezmoi/run_once_after_install-system-configs.sh
```

### 5. 設定の確認

```bash
# 適用されたファイルを確認
chezmoi managed

# 差分を確認
chezmoi diff
```

## cloud-initでの利用

cloud-initを使用して自動的にツールのインストールとdotfilesの適用ができます。

**cloud-initで実行される処理：**
1. 必要なツール（Docker, Go, Helm, gcloud, Ansibleなど）をデプロイタイプに応じて自動インストール
2. chezmoiのインストール
3. dotfilesの自動適用

**使用方法：**
1. `cloud-init.yaml`ファイルを編集して環境変数（`DEPLOYMENT_TYPE`、`PROXY_HOST`等）をカスタマイズ
2. クラウドインスタンス作成時にcloud-init設定として指定

```bash
# AWS EC2の例
aws ec2 run-instances \
  --image-id ami-xxxxx \
  --instance-type t2.micro \
  --user-data file://cloud-init.yaml
```

**注意：** ツールのインストールはcloud-initで行われるため、`run_once_before_install-packages.sh.tmpl`は最小限のディレクトリ作成とパーミッション設定のみを行います。

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

### 外部ツール管理

chezmoiの外部ファイル機能を使用して、apt管理外のツールを自動インストール：

- **Kubernetes関連**: kubectl, kubectx/kubens, k9s, stern, kind
- **Infrastructure as Code**: terraform, yq
- **Docker関連**: lazydocker, dive, ctop
- **Ansible関連**: ansible-lint, ansible-navigator

詳細は [EXTERNAL_TOOLS.md](EXTERNAL_TOOLS.md) を参照してください。

### システム設定ファイル (`/etc`)

システムレベルの設定ファイルを管理（要sudo）：

- **ネットワークチューニング**: `/etc/sysctl.d/99-network-tuning.conf`
- **システムワイドプロキシ**: `/etc/environment.d/proxy.conf`

詳細は [EXTERNAL_TOOLS.md](EXTERNAL_TOOLS.md) を参照してください。

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