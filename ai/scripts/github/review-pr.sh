#!/bin/bash

# GitHub プルリクエスト コードレビュースクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 前提条件チェック
check_prerequisites

# PR 番号を取得
PR_NUMBER="${1:-}"

if [[ -z "$PR_NUMBER" ]]; then
    log_info "PR 番号を取得します..."

    # 開いている PR 一覧を取得
    local prs=$(gh pr list --state open --json number,title,author,headRefName,baseRefName --limit 20)

    if [[ -z "$prs" ]] || [[ "$prs" == "[]" ]]; then
        log_warning "開いている PR がありません"
        exit 0
    fi

    # PR 一覧を表示
    log_info "開いている PR："
    echo "$prs" | jq -r '.[] | "#\(.number) - \(.title) (作成者: \(.author.login), \(.headRefName) → \(.baseRefName))"'

    # ユーザーに PR 番号を入力させる
    PR_NUMBER=$(prompt_user "PR 番号を入力")
fi

# PR 番号を抽出（URL の場合）
PR_NUMBER=$(extract_pr_number "$PR_NUMBER" || exit 1)

log_info "PR #$PR_NUMBER のレビュー準備中..."

# PR 情報を取得
local pr_data=$(gh pr view "$PR_NUMBER" \
    --json number,title,body,author,state,headRefName,baseRefName,url \
    2>/dev/null)

if [[ $? -ne 0 ]]; then
    log_error "PR #$PR_NUMBER が見つかりません"
    exit 1
fi

# フィールドを抽出
local pr_number=$(echo "$pr_data" | jq -r '.number')
local title=$(echo "$pr_data" | jq -r '.title')
local body=$(echo "$pr_data" | jq -r '.body // ""')
local author=$(echo "$pr_data" | jq -r '.author.login')
local state=$(echo "$pr_data" | jq -r '.state')
local head_branch=$(echo "$pr_data" | jq -r '.headRefName')
local base_branch=$(echo "$pr_data" | jq -r '.baseRefName')
local url=$(echo "$pr_data" | jq -r '.url')

log_success "PR 情報を取得しました"
echo ""

# PR の状態確認
if [[ "$state" != "OPEN" ]]; then
    log_warning "この PR は $state 状態です。レビューをスキップします。"
    exit 0
fi

echo "## PR 情報"
echo "- PR 番号: #$pr_number"
echo "- タイトル: $title"
echo "- 作成者: $author"
echo "- ブランチ: $head_branch → $base_branch"
echo ""

# 差分情報を取得
log_info "変更内容を確認中..."

# フェッチ
git fetch origin "$head_branch" "$base_branch" 2>/dev/null || true

# 変更ファイルを取得
local changed_files=$(git diff origin/"$base_branch"...origin/"$head_branch" --name-only 2>/dev/null)

echo "## 変更ファイル"
echo "$changed_files" | nl
echo ""

# コミット情報を表示
log_info "コミット履歴を確認中..."
local commits=$(git log origin/"$base_branch"..origin/"$head_branch" --oneline 2>/dev/null)

echo "## コミット履歴"
echo "$commits"
echo ""

# レビュー観点を表示
echo "## コードレビー観点"
echo ""
echo "以下の観点でレビューしてください："
echo ""
echo "1. **コーディング規約** (@docs/CODING_RULE.md)"
echo "   - 命名規則は守られているか"
echo "   - インデントやフォーマットは統一されているか"
echo "   - 型安全性は確保されているか"
echo ""
echo "2. **ロジック・設計**"
echo "   - アルゴリズムは正しいか"
echo "   - パフォーマンスは問題ないか"
echo "   - エッジケースは処理されているか"
echo ""
echo "3. **テスト**"
echo "   - テストコードは追加されているか"
echo "   - テストカバレッジは十分か"
echo ""
echo "4. **セキュリティ**"
echo "   - セキュリティ脆弱性がないか"
echo "   - 認証・認可は正しく処理されているか"
echo ""
echo "5. **ドキュメント**"
echo "   - コメントは適切か"
echo "   - README や設計ドキュメントは更新されているか"
echo ""

# レビューコメントを入力
log_info "レビューコメントを入力してください（複数行対応）"
log_info "入力完了後、空行を入力してください"

local review_comment=""
local line
while IFS= read -r line; do
    if [[ -z "$line" ]]; then
        break
    fi
    review_comment+="$line"$'\n'
done

if [[ -z "$review_comment" ]]; then
    log_warning "コメントが空です。コメント投稿をスキップします。"
    exit 0
fi

echo ""
echo "## レビューコメント（確認）"
echo ""
echo "$review_comment"
echo ""

# 確認
if ! confirm "このコメントを投稿しますか？"; then
    log_warning "キャンセルしました"
    exit 0
fi

# コメント投稿
log_info "コメントを投稿中..."

if gh pr comment "$PR_NUMBER" --body "$review_comment"; then
    log_success "コメントを投稿しました"
    echo ""
    echo "# コードレビューを投稿しました"
    echo ""
    echo "- PR 番号: #$pr_number"
    echo "- URL: $url"
    echo "- タイトル: $title"
else
    log_error "コメント投稿に失敗しました"
    exit 1
fi
