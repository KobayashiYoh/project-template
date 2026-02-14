#!/bin/bash

# GitHub プルリクエスト作成スクリプト

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 前提条件チェック
check_prerequisites

# パラメータ解析
BASE_BRANCH="develop"
TITLE=""
BODY=""
REVIEWER=""

while [[ $# -gt 0 ]]; do
    case $1 in
        --title)
            TITLE="$2"
            shift 2
            ;;
        --base)
            BASE_BRANCH="$2"
            shift 2
            ;;
        --body)
            BODY="$2"
            shift 2
            ;;
        --reviewer)
            REVIEWER="$2"
            shift 2
            ;;
        *)
            log_error "不明なオプション: $1"
            exit 1
            ;;
    esac
done

# 現在のブランチを取得
log_info "現在のブランチを確認中..."
CURRENT_BRANCH=$(git branch --show-current)

# ブランチバリデーション
if [[ "$CURRENT_BRANCH" == "main" ]] || [[ "$CURRENT_BRANCH" == "master" ]] || [[ "$CURRENT_BRANCH" == "$BASE_BRANCH" ]]; then
    log_error "このブランチからは PR を作成できません: $CURRENT_BRANCH"
    exit 1
fi

log_success "現在のブランチ: $CURRENT_BRANCH"
echo ""

# ローカルとリモートを同期
log_info "リモートへ push 中..."
git push -u origin "$CURRENT_BRANCH" 2>/dev/null || {
    log_error "push に失敗しました"
    exit 1
}
log_success "push 完了"
echo ""

# タイトルの自動生成（ブランチ名から）
if [[ -z "$TITLE" ]]; then
    log_info "タイトルを生成中..."

    # ブランチ名の形式: feature/123_add_new_feature -> "123 新機能を追加"
    if [[ $CURRENT_BRANCH =~ ^(feature|fix|refactor)/([0-9]+)_(.+)$ ]]; then
        local issue_num="${BASH_REMATCH[2]}"
        local feature_name="${BASH_REMATCH[3]}"

        # アンダースコアをスペースに置換
        feature_name="${feature_name//_/ }"

        TITLE="#$issue_num $feature_name"
    else
        log_warning "ブランチ名から自動生成できませんでした"
        TITLE=$(prompt_user "PR タイトルを入力してください")
    fi
fi

log_success "タイトル: $TITLE"
echo ""

# body の生成
if [[ -z "$BODY" ]]; then
    log_info "コミット履歴から body を生成中..."

    # コミット履歴を取得
    local commits=$(git log "$BASE_BRANCH".."$CURRENT_BRANCH" --oneline)

    BODY="## 変更内容

以下の変更を行いました：

\`\`\`
$commits
\`\`\`

## チェックリスト

- [ ] コードを確認した
- [ ] テストを実行した
- [ ] ドキュメントを更新した
"
fi

echo "## PR Body"
echo "$BODY"
echo ""

# 確認
if ! confirm "この内容で PR を作成しますか？"; then
    log_warning "キャンセルしました"
    exit 0
fi

echo ""
log_info "プルリクエストを作成中..."

# PR の作成
local pr_output=$(gh pr create \
    --base "$BASE_BRANCH" \
    --head "$CURRENT_BRANCH" \
    --title "$TITLE" \
    --body "$BODY" \
    --web 2>&1)

if [[ $? -eq 0 ]]; then
    log_success "プルリクエストを作成しました"

    # PR 番号と URL を抽出
    local pr_url=$(echo "$pr_output" | grep -oP 'https://github\.com/[^/]+/[^/]+/pull/\d+' | head -1)

    if [[ -n "$pr_url" ]]; then
        local pr_number=$(echo "$pr_url" | grep -oP 'pull/\d+' | cut -d'/' -f2)

        echo ""
        echo "# プルリクエストを作成しました"
        echo ""
        echo "- PR 番号: #$pr_number"
        echo "- URL: $pr_url"
        echo "- Source: $CURRENT_BRANCH"
        echo "- Target: $BASE_BRANCH"
        echo ""
        log_success "ブラウザで PR ページを開きます"
    else
        log_warning "PR 情報を抽出できませんでした"
    fi
else
    log_error "PR 作成に失敗しました"
    exit 1
fi
