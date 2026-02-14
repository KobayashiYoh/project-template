---
description: プルリクエストを自動作成する。
---

新しいプルリクエストを作成します。

## 実行方法

```bash
ai/scripts/github/create-pr.sh [オプション]
```

詳細は @ai/scripts/github/README.md を参照してください。

## 処理の流れ

1. ブランチを確認（main/develop は不可）
2. リモートへ push
3. PR タイトル・body を自動生成
4. 確認後、PR を作成して自動表示

## ブランチ命名規則

- `feature/123_add_new_feature` → PR タイトル："123 新機能を追加"
- body に `Closes #123` で Issue を自動クローズ
