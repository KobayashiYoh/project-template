---
description: ユーザーと対話しながら GitHub Issue を作成する。
---

実装内容をユーザーと相談しながら GitHub Issue を作成します。

## 実行方法

```bash
ai/scripts/github/create-issue.sh
```

## 実行フロー

1. Issue のタイプを選択（Feature / Bug）
2. タイプに応じた情報を質問して入力を促す
3. 入力内容を確認
4. GitHub Issue として作成

## Issue のタイプ別処理

### Feature（新機能）
- 機能の概要
- 実装したい内容
- その他補足（オプション）

### Bug（バグ）
- バグの説明
- 再現手順
- 期待される動作
- 実際の動作
- 環境情報
- その他補足（オプション）

## 前提条件

- GitHub CLI がインストールされていること
- GitHub CLI で認証済みであること
- Git リポジトリ内で実行すること

## 実行例

```bash
$ ai/scripts/github/create-issue.sh
ℹ GitHub Issue を作成します

ℹ Issue のタイプを選択してください
  1) Feature (新機能)
  2) Bug (バグ)
? 番号を選択: 1

ℹ Issue タイプ: feature
? Issue のタイトルを入力: ユーザー認証機能の追加
...
```
