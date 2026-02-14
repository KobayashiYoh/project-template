# GitHub CLI スクリプト集

このディレクトリには、GitHub CLI を使用した自動化スクリプトが含まれています。

## 前提条件

### インストール

1. **GitHub CLI のインストール**

```bash
# macOS (Homebrew)
brew install gh

# Linux (Debian/Ubuntu)
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh

# Windows (Chocolatey)
choco install gh
```

2. **GitHub 認証**

```bash
gh auth login
```

### セットアップ

スクリプトに実行権限を付与：

```bash
chmod +x fetch-issue.sh create-pr.sh update-pr.sh explain-pr.sh
```

## スクリプト一覧

### 1. fetch-issue.sh - Issue 情報取得

GitHub Issue の詳細情報を取得して表示します。

**使用法:**
```bash
./fetch-issue.sh [Issue番号またはURL]
```

**例:**
```bash
./fetch-issue.sh 123
./fetch-issue.sh https://github.com/user/repo/issues/123
./fetch-issue.sh  # 対話的に Issue を選択
```

**出力内容:**
- 基本情報（番号、URL、タイトル、状態）
- 作成者・担当者
- ラベル
- 説明（body）
- 作成日時・更新日時
- コメント一覧

---

### 2. create-pr.sh - プルリクエスト作成

新しいプルリクエストを作成します。

**使用法:**
```bash
./create-pr.sh [オプション]
```

**オプション:**
- `--title "タイトル"` - PR タイトル（省略時はブランチ名から自動生成）
- `--base develop` - マージ先ブランチ（デフォルト: develop）
- `--body "説明"` - PR 説明（省略時はコミット履歴から自動生成）
- `--reviewer "username"` - レビュアー指定

**例:**
```bash
./create-pr.sh
./create-pr.sh --title "新機能を追加" --base main
./create-pr.sh --reviewer "user1" --reviewer "user2"
```

**処理内容:**
1. 現在のブランチの確認
2. リモートへの push
3. PR タイトル・説明の自動生成（またはユーザー入力）
4. PR 作成確認
5. PR 作成・ブラウザで表示

---

### 3. update-pr.sh - PR の説明更新

既存のプルリクエストの説明（body）を更新します。

**使用法:**
```bash
./update-pr.sh [PR番号またはURL]
```

**例:**
```bash
./update-pr.sh 42
./update-pr.sh https://github.com/user/repo/pull/42
./update-pr.sh  # 対話的に PR を選択
```

**処理内容:**
1. PR 情報の取得
2. 現在の説明を表示
3. コミット履歴の確認
4. 新しい説明をユーザーが入力
5. 更新確認
6. PR 更新

---

### 4. explain-pr.sh - PR 内容の解説

プルリクエストの実装内容を詳しく解説します。

**使用法:**
```bash
./explain-pr.sh [PR番号またはURL]
```

**例:**
```bash
./explain-pr.sh 42
./explain-pr.sh https://github.com/user/repo/pull/42
./explain-pr.sh  # 対話的に PR を選択
```

**出力内容:**
- 基本情報（PR 番号、URL、タイトル、作成者）
- PR の概要（body の内容）
- コミット履歴
- 変更ファイル一覧
- 変更統計（追加行数・削除行数・ファイル数）
- レビューポイント

---

### 5. review-pr.sh - コードレビュー

プルリクエストのコードレビューを実施し、レビューコメントを投稿します。

**使用法:**
```bash
./review-pr.sh [PR番号またはURL]
```

**例:**
```bash
./review-pr.sh 42
./review-pr.sh https://github.com/user/repo/pull/42
./review-pr.sh  # 対話的に PR を選択
```

**処理内容:**
1. PR 情報の取得
2. 変更ファイル一覧・コミット履歴の確認
3. レビュー観点の提示
4. ユーザーがレビューコメントを入力
5. 確認後に GitHub に投稿

**レビュー観点:**
- コーディング規約の遵守
- ロジック・設計
- テストカバレッジ
- セキュリティ
- ドキュメント更新

---

## 使用例

### Issue を確認してから PR を作成

```bash
# Issue 情報を確認
./fetch-issue.sh 123

# Issue の内容を踏まえて PR を作成
./create-pr.sh --title "Issue #123 を解決"
```

### PR の説明を更新

```bash
# 現在の PR を確認
./explain-pr.sh 42

# 説明を更新
./update-pr.sh 42
```

---

## ヘルパーライブラリ

`lib/common.sh` には、よく使用される関数が定義されています：

- `log_info()` - 情報ログ
- `log_success()` - 成功ログ
- `log_warning()` - 警告ログ
- `log_error()` - エラーログ
- `check_prerequisites()` - GitHub CLI と認証の確認
- `prompt_user()` - ユーザー入力
- `confirm()` - ユーザー確認
- `select_from_list()` - リストからの選択
- `extract_issue_number()` - Issue URL から番号抽出
- `extract_pr_number()` - PR URL から番号抽出

---

## トラブルシューティング

### "GitHub CLI がインストールされていません"

```bash
# GitHub CLI をインストール
brew install gh  # macOS
# または上記の他 OS のインストール手順を参照
```

### "GitHub CLI が認証されていません"

```bash
# 認証を実行
gh auth login
```

### "リポジトリが見つかりません"

- Git リポジトリのルートディレクトリから実行
- リモートが設定されているか確認：`git remote -v`

### スクリプトが実行できない

```bash
# 実行権限を付与
chmod +x *.sh
```

---

## 参考資料

- [GitHub CLI ドキュメント](https://cli.github.com/manual)
- [gh コマンドリファレンス](https://cli.github.com/)
- [GitHub API ドキュメント](https://docs.github.com/en/rest)
