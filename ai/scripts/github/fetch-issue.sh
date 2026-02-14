#!/bin/bash

# GitHub Issue 情報取得スクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 前提条件チェック
check_prerequisites

# Issue 番号を取得
ISSUE_NUMBER="${1:-}"

if [[ -z "$ISSUE_NUMBER" ]]; then
    log_info "Issue 番号を取得します..."

    # 開いている Issue 一覧を取得
    local issues=$(gh issue list --state open --json number,title,author,labels --limit 20)

    if [[ -z "$issues" ]] || [[ "$issues" == "[]" ]]; then
        log_warning "開いている Issue がありません"
        exit 0
    fi

    # Issue 一覧を表示
    log_info "開いている Issue："
    echo "$issues" | jq -r '.[] | "\(.number) - \(.title) (作成者: \(.author.login))"'

    # ユーザーに Issue 番号を入力させる
    ISSUE_NUMBER=$(prompt_user "Issue 番号を入力")
fi

# Issue 番号を抽出（URL の場合）
ISSUE_NUMBER=$(extract_issue_number "$ISSUE_NUMBER" || exit 1)

log_info "Issue #$ISSUE_NUMBER の情報を取得中..."

# Issue 情報を取得
local issue_data=$(gh issue view "$ISSUE_NUMBER" \
    --json number,title,body,author,state,labels,assignees,createdAt,updatedAt,url,comments \
    2>/dev/null)

if [[ $? -ne 0 ]]; then
    log_error "Issue #$ISSUE_NUMBER が見つかりません"
    exit 1
fi

# フィールドを抽出
local issue_number=$(echo "$issue_data" | jq -r '.number')
local title=$(echo "$issue_data" | jq -r '.title')
local body=$(echo "$issue_data" | jq -r '.body // "情報なし"')
local author=$(echo "$issue_data" | jq -r '.author.login')
local state=$(echo "$issue_data" | jq -r '.state')
local labels=$(echo "$issue_data" | jq -r '.labels | map(.name) | join(", ") // "ラベルなし"')
local assignees=$(echo "$issue_data" | jq -r '.assignees | map(.login) | join(", ") // "担当者なし"')
local created_at=$(echo "$issue_data" | jq -r '.createdAt')
local updated_at=$(echo "$issue_data" | jq -r '.updatedAt')
local url=$(echo "$issue_data" | jq -r '.url')
local comments=$(echo "$issue_data" | jq -r '.comments | length')

# コメント情報を取得
local comments_detail=""
if ((comments > 0)); then
    comments_detail=$(gh issue view "$ISSUE_NUMBER" \
        --json comments \
        --jq '.comments[] | "**\(.author.login)** (\(.createdAt))\n\(.body)\n"' \
        2>/dev/null)
fi

# 状態を日本語に変換
local state_ja
case "$state" in
    OPEN)
        state_ja="オープン"
        ;;
    CLOSED)
        state_ja="クローズ"
        ;;
    *)
        state_ja="$state"
        ;;
esac

# 出力
log_success "Issue 情報を取得しました"
echo ""
echo "# Issue #$issue_number 情報"
echo ""
echo "## 基本情報"
echo "- Issue 番号: #$issue_number"
echo "- Issue URL: $url"
echo "- タイトル: $title"
echo "- 状態: $state_ja"
echo "- 作成者: $author"
echo "- 担当者: $assignees"
echo ""
echo "## ラベル"
if [[ "$labels" != "ラベルなし" ]]; then
    echo "$labels" | tr ',' '\n' | sed 's/^ /- /'
else
    echo "- ラベルなし"
fi
echo ""
echo "## 説明"
echo "$body"
echo ""
echo "## タイムライン"
echo "- 作成日時: $created_at"
echo "- 最終更新日時: $updated_at"
echo "- コメント数: $comments"
echo ""

if ((comments > 0)); then
    echo "## コメント"
    echo "$comments_detail"
fi

log_success "処理完了"
