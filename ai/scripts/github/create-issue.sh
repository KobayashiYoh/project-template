#!/bin/bash

# GitHub Issue 作成スクリプト
# ユーザーと対話しながら Issue を作成します

set -e

# スクリプトのディレクトリを取得
SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
source "$SCRIPT_DIR/lib/common.sh"

# 前提条件チェック
check_prerequisites

echo ""
log_info "GitHub Issue を作成します"
echo ""

# Issue タイプの選択
ISSUE_TYPE=$(select_from_list "Issue のタイプを選択してください" "Feature (新機能)" "Bug (バグ)")

if [[ "$ISSUE_TYPE" == "Feature (新機能)" ]]; then
    ISSUE_TYPE="feature"
elif [[ "$ISSUE_TYPE" == "Bug (バグ)" ]]; then
    ISSUE_TYPE="bug"
fi

echo ""
log_info "Issue タイプ: $ISSUE_TYPE"
echo ""

# タイトルの入力
TITLE=$(prompt_user "Issue のタイトルを入力")
echo ""

# 本文の作成（タイプ別）
case "$ISSUE_TYPE" in
    feature)
        log_info "Feature の情報を入力してください"
        echo ""

        OVERVIEW=$(prompt_user "機能の概要")
        echo ""

        IMPLEMENTATION=$(prompt_user "実装したい内容")
        echo ""

        OTHER=$(prompt_user "その他補足（不要な場合はEnterキー）" "")
        echo ""

        BODY="## 機能の概要

$OVERVIEW

## 実装したい内容

$IMPLEMENTATION"

        if [[ -n "$OTHER" ]]; then
            BODY="$BODY

## その他

$OTHER"
        fi
        ;;
    bug)
        log_info "Bug の情報を入力してください"
        echo ""

        DESCRIPTION=$(prompt_user "バグの説明")
        echo ""

        STEPS=$(prompt_user "再現手順（番号付きで、例: 1. 〇〇をクリック 2. △△が起きる）")
        echo ""

        EXPECTED=$(prompt_user "期待される動作")
        echo ""

        ACTUAL=$(prompt_user "実際の動作")
        echo ""

        ENVIRONMENT=$(prompt_user "環境情報（例: macOS 14, Safari）")
        echo ""

        OTHER=$(prompt_user "その他補足（不要な場合はEnterキー）" "")
        echo ""

        BODY="## バグの説明

$DESCRIPTION

## 再現手順

$STEPS

## 期待される動作

$EXPECTED

## 実際の動作

$ACTUAL

## 環境

$ENVIRONMENT"

        if [[ -n "$OTHER" ]]; then
            BODY="$BODY

## その他

$OTHER"
        fi
        ;;
esac

# 確認
echo ""
log_info "以下の内容で Issue を作成します"
echo ""
echo "## タイトル"
echo "$TITLE"
echo ""
echo "## 本文"
echo "$BODY"
echo ""

if ! confirm "この内容で Issue を作成しますか？"; then
    log_warning "キャンセルしました"
    exit 0
fi

echo ""
log_info "Issue を作成中..."

# Issue を作成
ISSUE_OUTPUT=$(gh issue create \
    --title "$TITLE" \
    --body "$BODY" 2>&1)

if [[ $? -eq 0 ]]; then
    # Issue URL を抽出
    ISSUE_URL=$(echo "$ISSUE_OUTPUT" | grep -oP 'https://github\.com/[^/]+/[^/]+/issues/\d+' | head -1)

    if [[ -n "$ISSUE_URL" ]]; then
        ISSUE_NUMBER=$(echo "$ISSUE_URL" | grep -oP 'issues/\d+' | cut -d'/' -f2)

        echo ""
        log_success "Issue を作成しました"
        echo ""
        echo "# Issue #$ISSUE_NUMBER を作成しました"
        echo ""
        echo "- Issue 番号: #$ISSUE_NUMBER"
        echo "- URL: $ISSUE_URL"
        echo "- タイプ: $ISSUE_TYPE"
        echo ""
    else
        log_warning "Issue 情報を抽出できませんでした"
        echo "$ISSUE_OUTPUT"
    fi
else
    log_error "Issue 作成に失敗しました"
    exit 1
fi
