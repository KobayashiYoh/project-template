#!/bin/bash

# GitHub CLI 共通関数ライブラリ

# カラー定義
RED='\033[0;31m'
GREEN='\033[0;32m'
YELLOW='\033[1;33m'
BLUE='\033[0;34m'
NC='\033[0m'

# 情報ログを出力
log_info() {
    echo -e "${BLUE}ℹ${NC} $1"
}

# 成功ログを出力
log_success() {
    echo -e "${GREEN}✓${NC} $1"
}

# 警告ログを出力
log_warning() {
    echo -e "${YELLOW}⚠${NC} $1"
}

# エラーログを出力（標準エラーに出力）
log_error() {
    echo -e "${RED}✗${NC} $1" >&2
}

# GitHub CLI がインストールされているか確認
check_gh_installed() {
    if ! command -v gh &> /dev/null; then
        log_error "GitHub CLI がインストールされていません"
        log_info "インストール方法: https://cli.github.com"
        exit 1
    fi
}

# GitHub に認証されているか確認
check_gh_auth() {
    if ! gh auth status &> /dev/null; then
        log_error "GitHub CLI が認証されていません"
        log_info "認証実行: gh auth login"
        exit 1
    fi

    local auth_status=$(gh auth status 2>&1)
    if echo "$auth_status" | grep -q "not logged in"; then
        log_error "GitHub に認証されていません"
        exit 1
    fi
}

# Git リポジトリかどうか確認
check_git_repo() {
    if ! git rev-parse --git-dir > /dev/null 2>&1; then
        log_error "Git リポジトリではありません"
        exit 1
    fi
}

# リポジトリ情報を取得（owner/repo フォーマット）
get_repo_info() {
    local repo_info=$(gh repo view --json nameWithOwner --jq '.nameWithOwner' 2>/dev/null)

    if [[ -z "$repo_info" ]]; then
        log_error "リポジトリ情報を取得できません"
        exit 1
    fi

    echo "$repo_info"
}

# 前提条件をすべてチェック（GitHub CLI、Git リポジトリ、認証）
check_prerequisites() {
    check_gh_installed
    check_git_repo
    check_gh_auth
}

# Issue URL または番号から Issue 番号を抽出
extract_issue_number() {
    local url="$1"

    if [[ $url =~ /issues/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ $url =~ ^[0-9]+$ ]]; then
        echo "$url"
    else
        log_error "無効な Issue URL または番号: $url"
        return 1
    fi
}

# PR URL または番号から PR 番号を抽出
extract_pr_number() {
    local url="$1"

    if [[ $url =~ /pull/([0-9]+) ]]; then
        echo "${BASH_REMATCH[1]}"
    elif [[ $url =~ ^[0-9]+$ ]]; then
        echo "$url"
    else
        log_error "無効な PR URL または番号: $url"
        return 1
    fi
}

# ユーザーに入力を促す（デフォルト値オプション）
# 例: prompt_user "入力" "デフォルト値"
prompt_user() {
    local prompt="$1"
    local default="$2"
    local input

    if [[ -z "$default" ]]; then
        read -p "$(echo -e ${BLUE}?)${NC} $prompt: " input
    else
        read -p "$(echo -e ${BLUE}?)${NC} $prompt (デフォルト: $default): " input
        input="${input:-$default}"
    fi

    echo "$input"
}

# ユーザーに yes/no で確認を取る
# 例: confirm "実行しますか？" && echo "実行" || echo "キャンセル"
confirm() {
    local prompt="$1"
    local response

    while true; do
        read -p "$(echo -e ${BLUE}?)${NC} $prompt (y/n): " response
        case "$response" in
            [yY][eE][sS]|[yY])
                return 0
                ;;
            [nN][oO]|[nN])
                return 1
                ;;
            *)
                log_warning "y または n で答えてください"
                ;;
        esac
    done
}

# リストからユーザーに選択させる
# 例: select_from_list "選択" "オプション1" "オプション2"
select_from_list() {
    local prompt="$1"
    shift
    local options=("$@")
    local selected

    log_info "$prompt"
    for i in "${!options[@]}"; do
        echo "  $((i+1))) ${options[$i]}"
    done

    while true; do
        read -p "$(echo -e ${BLUE}?)${NC} 番号を選択: " selected

        if [[ $selected =~ ^[0-9]+$ ]] && ((selected > 0 && selected <= ${#options[@]})); then
            echo "${options[$((selected-1))]}"
            return 0
        else
            log_warning "1 から ${#options[@]} の数値を入力してください"
        fi
    done
}

# JSON をフォーマットして表示
pretty_json() {
    local json="$1"
    echo "$json" | jq '.' 2>/dev/null || echo "$json"
}

# HTML タグを簡易的にマークダウン変換
html_to_markdown() {
    local html="$1"

    html="${html//<br>/
}"
    html="${html//<br \/>/
}"
    html="${html//<p>/}"
    html="${html/<\/p>/
}"
    html="${html//<strong>/\*\*}"
    html="${html/<\/strong>/\*\*}"
    html="${html//<em>/\*}"
    html="${html/<\/em>/\*}"

    echo "$html"
}

export -f log_info log_success log_warning log_error
export -f check_gh_installed check_gh_auth check_git_repo
export -f check_prerequisites get_repo_info
export -f extract_issue_number extract_pr_number
export -f prompt_user confirm select_from_list
export -f pretty_json html_to_markdown
