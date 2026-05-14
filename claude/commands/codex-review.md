# Codex でコードレビュー

Codex CLI を使って現在の変更をレビューしてください。

## 手順

1. まず状態を確認:
   - `git status` で未コミットの変更があるか確認
   - `git branch --show-current` で現在のブランチを確認
   - `git symbolic-ref refs/remotes/origin/HEAD | sed 's@^refs/remotes/origin/@@'` でデフォルトブランチを取得

2. 状態に応じて適切な `codex review` を実行:
   - **未コミットの変更がある場合**: `codex review --uncommitted` を実行
   - **デフォルトブランチ以外のブランチにいる場合** (未コミット変更なし): `codex review --base <デフォルトブランチ>` を実行
   - **両方ある場合**: `codex review --uncommitted` を優先実行（まず手元の変更をレビュー）

3. Codex の出力結果をそのまま表示

## 注意
- `codex review` は非対話的に実行される
- レビュー結果が長い場合でも省略せず全文を表示すること
