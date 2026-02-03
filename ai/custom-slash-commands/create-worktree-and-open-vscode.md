---
description: worktreeで別ブランチを作成し、VSCodeの別ウィンドウで開く。並列開発用。
---

まず、@docs/GIT_RULE.md を参照してください。

以下の手順で新しいワークスペースを作成してVSCodeで開いて：

1. ユーザーに実装内容を確認する（まだ指定されていない場合）
2. デフォルトブランチを最新に更新する（GIT_RULE.mdを参照してデフォルトブランチを確認し、`git checkout [デフォルトブランチ]` して `git pull origin [デフォルトブランチ]` を実行）
3. 実装内容を踏まえて適切なブランチ名を考える（GIT_RULE.mdのブランチ命名規則に従う）
4. `git worktree add ../../other_projects/[ブランチ名] -b [ブランチ名]` でデフォルトブランチからworktreeを作成（`emot/other_projects`配下に作成）
5. `code ../../other_projects/[ブランチ名]` で新しいVSCodeウィンドウを開く

注意：
- 既に同名のworktreeが存在する場合はエラーを伝える
- VSCodeが開いたことを確認したら完了
