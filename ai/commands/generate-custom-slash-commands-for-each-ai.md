---
description: ai/commandsディレクトリを元に、各種AIごとのスラッシュコマンドを生成する。
---

各種AIツールで同様のスラッシュコマンドを利用できるようにするため、 `ai/commands` ディレクトリを参照し、以下のディレクトリに同じファイル名が存在しない場合はファイルを生成して。

- .claude/skills/{command-name}/SKILL.md
- .github/prompts/{command-name}.prompt.md

その際、生成したファイルの中身は生成元へのファイルのパーマリンク（先頭が@のもの）のみを記載して。

生成が完了したら、`GIT_RULE.md`を読み、生成したファイルをコマンドの種類ごとにまとめてコミットして。
