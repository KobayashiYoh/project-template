---
description: 既存のプルリクエストのbodyを更新する。
---

プルリクエストの説明（body）を更新します。

## 実行方法

```bash
ai/scripts/github/update-pr.sh [PR番号またはURL]
```

詳細は @ai/scripts/github/README.md を参照してください。

## 処理

1. PR の body と コミット履歴を表示
2. 新しい body を入力
3. 確認後、PR を更新
