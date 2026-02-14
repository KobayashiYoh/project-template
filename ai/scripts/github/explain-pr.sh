#!/bin/bash

# GitHub プルリクエスト解説スクリプト

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
    --json number,title,body,author,state,headRefName,baseRefName,url,createdAt,updatedAt \
    2>/dev/null)

if [[ $? -ne 0 ]]; then
    log_error "PR #$PR_NUMBER が見つかりません"
    exit 1
fi

# フィールドを抽出
local pr_number=$(echo "$pr_data" | jq -r '.number')
local title=$(echo "$pr_data" | jq -r '.title')
local body=$(echo "$pr_data" | jq -r '.body // "説明なし"')
local author=$(echo "$pr_data" | jq -r '.author.login')
local state=$(echo "$pr_data" | jq -r '.state')
local head_branch=$(echo "$pr_data" | jq -r '.headRefName')
local base_branch=$(echo "$pr_data" | jq -r '.baseRefName')
local url=$(echo "$pr_data" | jq -r '.url')
local created_at=$(echo "$pr_data" | jq -r '.createdAt')
local updated_at=$(echo "$pr_data" | jq -r '.updatedAt')

log_success "PR 情報を取得しました"
echo ""

# コミット履歴を取得
log_info "コミット履歴を取得中..."
local commits=$(gh pr view "$PR_NUMBER" \
    --json commits \
    --jq '.commits[] | "- \(.oid | .[0:7]) \(.message | split("\n") | .[0]) (作成者: \(.author.login))"' \
    2>/dev/null)

echo "## 基本情報"
echo "- PR 番号: #$pr_number"
echo "- PR URL: $url"
echo "- タイトル: $title"
echo "- 作成者: $author"
echo "- ステータス: $state"
echo "- ソースブランチ: $head_branch"
echo "- ターゲットブランチ: $base_branch"
echo "- 作成日時: $created_at"
echo "- 更新日時: $updated_at"
echo ""

echo "## プルリクエストの概要"
echo "$body"
echo ""

echo "## コミット履歴"
if [[ -n "$commits" ]]; then
    echo "$commits"
else
    echo "コミットなし"
fi
echo ""

# 差分情報を取得（ローカルリポジトリがある場合）
if git rev-parse --git-dir > /dev/null 2>&1; then
    log_info "差分情報を取得中..."

    # フェッチ（念のため）
    git fetch origin "$head_branch" "$base_branch" 2>/dev/null || true

    # 変更されたファイル情報を取得
    local diff_stat=$(git diff origin/"$base_branch"...origin/"$head_branch" --stat 2>/dev/null || echo "差分取得失敗")

    echo "## 変更ファイル一覧"
    echo ""
    echo "\`\`\`"
    echo "$diff_stat"
    echo "\`\`\`"
    echo ""

    # 主要な変更内容の統計
    local changes=$(git diff origin/"$base_branch"...origin/"$head_branch" --numstat 2>/dev/null)

    if [[ -n "$changes" ]]; then
        # 追加・削除行数を集計
        local added=0
        local removed=0

        while IFS=$'\t' read -r add del file; do
            ((added += add))
            ((removed += del))
        done <<< "$changes"

        echo "## 変更統計"
        echo "- 追加行数: $added"
        echo "- 削除行数: $removed"
        echo "- 変更ファイル数: $(echo "$changes" | wc -l)"
        echo ""
    fi
else
    log_warning "ローカルリポジトリがないため、詳細な差分情報は表示できません"
    echo ""
fi

echo "## レビューポイント"
echo ""
echo "このプルリクエストをレビュアーが確認する際の重要なポイント："
echo ""
echo "1. **変更内容の確認**"
echo "   - 変更内容がタイトルと説明と一致しているか"
echo "   - 不要な変更が含まれていないか"
echo ""
echo "2. **コード品質**"
echo "   - コーディング規約に従っているか"
echo "   - テストが追加されているか"
echo ""
echo "3. **セキュリティ**"
echo "   - セキュリティの問題がないか"
echo "   - 認証・認可の処理が正しいか"
echo ""
echo "4. **パフォーマンス**"
echo "   - パフォーマンスへの影響はないか"
echo "   - 不要なループや処理がないか"
echo ""

log_success "処理完了"
