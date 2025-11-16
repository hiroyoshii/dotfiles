# Contributing Guide

dotfilesプロジェクトへの貢献を歓迎します！

## 開発環境のセットアップ

1. リポジトリをフォーク
2. ローカルにクローン

```bash
git clone https://github.com/YOUR_USERNAME/dotfiles.git
cd dotfiles
```

3. chezmoiをインストール

```bash
sh -c "$(curl -fsLS get.chezmoi.io)"
```

## 新しい設定の追加

### 1. テンプレートファイルの作成

chezmoiの命名規則に従ってファイルを作成：

- `dot_filename.tmpl` → `~/.filename`
- `dot_dir/file.tmpl` → `~/.dir/file`
- `run_once_script.sh.tmpl` → 初回のみ実行されるスクリプト

### 2. デプロイメントタイプの考慮

`.chezmoi.yaml.tmpl`で新しい機能フラグを追加：

```yaml
features:
  newfeature: {{ or (eq $deploymentType "all") (eq $deploymentType "cloud") }}
```

### 3. .chezmoiignoreの更新

必要に応じて、特定のデプロイメントタイプで除外：

```
{{- if not .features.newfeature }}
.newconfig
{{- end }}
```

### 4. テンプレートでの使用

```bash
{{- if .features.newfeature }}
# New feature configuration
{{- end }}
```

## プロキシ設定の追加

新しいツールにプロキシ設定を追加する場合：

```bash
{{- if .proxy.host }}
export HTTP_PROXY={{ .proxy.url }}
export HTTPS_PROXY={{ .proxy.httpsUrl }}
export NO_PROXY={{ .proxy.noProxy }}
{{- end }}
```

## テスト

変更をコミットする前に：

1. 各デプロイメントタイプでテスト

```bash
for type in all edge cloud onprem; do
  export DEPLOYMENT_TYPE=$type
  chezmoi apply --dry-run
done
```

2. プロキシあり/なしでテスト

```bash
# プロキシあり
export PROXY_HOST=proxy.test.com
chezmoi apply --dry-run

# プロキシなし
export PROXY_HOST=
chezmoi apply --dry-run
```

3. テンプレート構文チェック

```bash
# 全テンプレートファイルのbrace数チェック
for f in $(find . -name "*.tmpl"); do
  open=$(grep -o "{{" "$f" | wc -l)
  close=$(grep -o "}}" "$f" | wc -l)
  if [ $open -ne $close ]; then
    echo "ERROR: $f has unbalanced braces"
  fi
done
```

## Pull Requestの作成

1. 機能ブランチを作成

```bash
git checkout -b feature/add-new-tool
```

2. 変更をコミット

```bash
git add .
git commit -m "Add configuration for new tool"
```

3. プッシュ

```bash
git push origin feature/add-new-tool
```

4. GitHubでPull Requestを作成

### Pull Requestの内容

- 明確なタイトル
- 変更内容の説明
- 影響を受けるデプロイメントタイプ
- テスト方法
- 関連するIssueへのリンク

## コーディング規約

### ファイル構成

- テンプレートファイルは必ず`.tmpl`拡張子を使用
- コメントは`{{- /* comment */ -}}`形式で記述
- 環境変数は`.chezmoi.yaml.tmpl`で定義してから使用

### テンプレート記法

- 空白制御は`{{-`と`-}}`を適切に使用
- 条件分岐は読みやすく記述
- 複雑なロジックはスクリプトに分離

### ドキュメント

- 新しい機能を追加したらREADME.mdを更新
- 複雑な設定には使用例を追加
- コメントは日本語または英語で記述

## コミットメッセージ

明確で説明的なコミットメッセージを心がけてください：

```
Add Docker proxy configuration for edge deployment

- Add proxy settings to Docker daemon config
- Update documentation for Docker proxy setup
- Add test case for edge deployment type
```

## リリースプロセス

1. バージョンタグを作成
2. リリースノートを記述
3. 重要な変更点を強調

## 質問やサポート

- Issueで質問を投稿
- ディスカッションで議論
- PRでフィードバックを求める

ご協力ありがとうございます！
