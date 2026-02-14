#!/bin/bash

# スラッシュコマンドの自動生成スクリプト
# ai/commands ディレクトリを参照して、
# .claude と .github/prompts に同じファイルを生成する

set -e

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
PROJECT_ROOT="$(cd "$(dirname "${SCRIPT_DIR}")" && pwd)"

SOURCE_DIR="${PROJECT_ROOT}/ai/commands"
CLAUDE_DIR="${PROJECT_ROOT}/.claude/commands"
GITHUB_DIR="${PROJECT_ROOT}/.github/prompts"

# .claude/commands ディレクトリにファイルを生成
echo "Generating files in .claude/commands..."
for file in "${SOURCE_DIR}"/*.md; do
  filename=$(basename "$file")
  target="${CLAUDE_DIR}/$filename"
  if [ ! -f "$target" ]; then
    mkdir -p "${CLAUDE_DIR}"
    echo "@ai/commands/$filename" > "$target"
    echo "  Created: $filename"
  fi
done

# .github/prompts ディレクトリにファイルを生成
echo "Generating files in .github/prompts..."
for file in "${SOURCE_DIR}"/*.md; do
  filename=$(basename "$file" .md)
  target="${GITHUB_DIR}/${filename}.prompt.md"
  if [ ! -f "$target" ]; then
    mkdir -p "${GITHUB_DIR}"
    echo "@ai/commands/${filename}.md" > "$target"
    echo "  Created: ${filename}.prompt.md"
  fi
done

echo "Done!"
