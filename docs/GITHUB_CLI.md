# GitHub CLI セットアップガイド

GitHub CLI (`gh`) を使用して、Claude Code から GitHub のプルリクエストや Issue を管理するための前提条件と セットアップ方法です。

## 前提条件

### 1. GitHub CLI のインストール

GitHub CLI がインストールされていることを確認してください。

```bash
gh --version
```

インストールされていない場合は、以下のコマンドでインストール：

**macOS（Homebrew）:**
```bash
brew install gh
```

**Linux:**
```bash
curl -fsSL https://cli.github.com/packages/githubcli-archive-keyring.gpg | sudo dd of=/usr/share/keyrings/githubcli-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null
sudo apt update
sudo apt install gh
```

**Windows:**
```bash
choco install gh
```

### 2. GitHub への認証

GitHub CLI を使用する前に、GitHub に認証します：

```bash
gh auth login
```

対話的プロンプトで以下を選択：
- **What is your preferred protocol for Git operations?** → `HTTPS`
- **Authenticate Git with your GitHub credentials?** → `Y` または `y`
- **How would you like to authenticate GitHub CLI?** → `Paste an authentication token`

**トークン取得方法:**
1. GitHub.com にログイン
2. Settings > Developer settings > [Personal access tokens](https://github.com/settings/tokens)
3. Classic tokens を選択し「Generate new token」
4. 以下のスコープを有効化：
   - `repo` - リポジトリへのアクセス
   - `read:org` - 組織情報の読み取り
   - `gist` - Gist アクセス（オプション）
5. トークンを生成してコピー
6. CLI のプロンプトにペースト

### 3. 認証確認

```bash
gh auth status
```

出力例：
```
github.com
  ✓ Logged in to github.com as [your-username]
  ✓ Git operations for github.com configured to use HTTPS protocol.
  ✓ Token: gho_****...
  ✓ Token scopes: repo, read:org
```

### 4. リポジトリ設定

Github CLI がリポジトリを認識できるように、リポジトリディレクトリから実行します：

```bash
cd /path/to/repository
gh repo view
```

出力例：
```
dialect-translator
description: Language translation tool
visibility: public
```

## 主なコマンド

### プルリクエスト

#### 一覧表示
```bash
gh pr list --state open
gh pr list --state all
```

#### PR 詳細表示
```bash
gh pr view [PR番号]
gh pr view --web  # ブラウザで開く
```

#### PR 作成
```bash
gh pr create --title "タイトル" --body "説明" --head [ソースブランチ] --base [ターゲットブランチ]
```

#### PR 更新
```bash
gh pr edit [PR番号] --body "新しい説明"
```

#### レビュアー追加
```bash
gh pr edit [PR番号] --add-reviewer "@username"
```

#### PR をマージ
```bash
gh pr merge [PR番号] --squash
gh pr merge [PR番号] --rebase
gh pr merge [PR番号] --merge
```

### Issue

#### Issue 一覧
```bash
gh issue list --state open
gh issue list --state all
```

#### Issue 詳細表示
```bash
gh issue view [Issue番号]
gh issue view --web
```

#### Issue 作成
```bash
gh issue create --title "タイトル" --body "説明"
```

#### Issue 更新
```bash
gh issue edit [Issue番号] --body "新しい説明"
```

### リポジトリ情報

#### リポジトリ詳細
```bash
gh repo view
gh repo view [owner/repo]
```

#### ライセンス確認
```bash
gh api repos/{owner}/{repo}/license
```

## トラブルシューティング

### 認証エラー
```
gh: could not authenticate with GitHub
```

**解決方法:**
```bash
gh auth logout
gh auth login
```

### リポジトリが見つからない
```
gh: directory is not a git repository
```

**解決方法:**
- Git リポジトリのルートディレクトリから実行
- リモートが設定されているか確認：`git remote -v`

### API レート制限エラー
```
API rate limit exceeded
```

GitHub の API レート制限に達しました。1 時間待機するか、トークンを確認してください。

## 便利なエイリアス

`.bashrc` または `.zshrc` に以下を追加：

```bash
alias ghpl='gh pr list --state open'
alias ghil='gh issue list --state open'
alias ghprv='gh pr view --web'
alias ghiv='gh issue view --web'
```

## 参考リンク

- [GitHub CLI 公式ドキュメント](https://cli.github.com/manual)
- [gh コマンドリファレンス](https://cli.github.com/)
- [GitHub API ドキュメント](https://docs.github.com/en/rest)
