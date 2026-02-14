#!/bin/bash

# GitHub プルリクエスト更新スクリプト

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

log_info "PR #$PR_NUMBER の情報を取得中..."

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
local current_body=$(echo "$pr_data" | jq -r '.body // ""')
local author=$(echo "$pr_data" | jq -r '.author.login')
local head_branch=$(echo "$pr_data" | jq -r '.headRefName')
local base_branch=$(echo "$pr_data" | jq -r '.baseRefName')
local url=$(echo "$pr_data" | jq -r '.url')

log_success "PR 情報を取得しました"
echo ""

# 現在の body を表示
echo "## 現在の Body"
echo ""
if [[ -z "$current_body" ]]; then
    echo "(空)"
else
    echo "$current_body"
fi
echo ""

# 差分情報を取得
log_info "変更内容を確認中..."
local commits=$(git log "$base_branch".."$head_branch" --oneline 2>/dev/null || echo "ローカルブランチなし")

echo "## コミット履歴"
echo ""
echo "$commits"
echo ""

# 新しい body を入力
log_info "新しい body を入力してください（複数行対応）"
log_info "入力完了後、空行を入力してください"

local new_body=""
local line
while IFS= read -r line; do
    if [[ -z "$line" ]]; then
        break
    fi
    new_body+="$line"$'\n'
done

if [[ -z "$new_body" ]]; then
    log_warning "body が空です。現在の body を保持します"
    new_body="$current_body"
fi

echo ""
echo "## 新しい Body"
echo ""
echo "$new_body"
echo ""

# 確認
if ! confirm "この内容で PR を更新しますか？"; then
    log_warning "キャンセルしました"
    exit 0
fi

echo ""
log_info "プルリクエストを更新中..."

# PR を更新
if gh pr edit "$PR_NUMBER" --body "$new_body" 2>/dev/null; then
    log_success "プルリクエストを更新しました"

    echo ""
    echo "# プルリクエストの body を更新しました"
    echo ""
    echo "- PR 番号: #$pr_number"
    echo "- URL: $url"
    echo "- タイトル: $title"
    echo "- Source: $head_branch"
    echo "- Target: $base_branch"
else
    log_error "PR 更新に失敗しました"
    exit 1
fi
