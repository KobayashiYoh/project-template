---
description: GitHubからプルリクエストを取得し、実装内容を詳しく解説する。
---

プルリクエストの実装内容を詳しく解説します。

## 実行方法

```bash
ai/scripts/github/explain-pr.sh [PR番号またはURL]
```

詳細は @ai/scripts/github/README.md を参照してください。

## 出力内容

- 基本情報（PR 番号、URL、タイトル、作成者）
- 概要、コミット履歴、変更ファイル一覧
- 変更統計、レビューポイント

## 評価観点

@docs/coding-rules/CODING_RULE_COMMON.md に従い：
- コーディング規約への準拠
- テストカバレッジ
- セキュリティとパフォーマンス
