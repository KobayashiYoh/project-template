---
description: GitHubからIssue情報を取得して表示する。
---

GitHub Issue の詳細情報を取得して表示します。

## 実行方法

```bash
ai/scripts/github/fetch-issue.sh [Issue番号またはURL]
```

詳細は @ai/scripts/github/README.md を参照してください。

## 出力内容

- 基本情報（Issue 番号、URL、タイトル、状態）
- 作成者・担当者、ラベル
- 説明内容、作成日時、コメント一覧
