# X 検索スキルでインライン curl を採用

xAI API の `x_search` は単一 API コールで完結するため、外部スクリプト (TypeScript 等) を使わずスキル Markdown 内に curl コマンドを直接記述する。既存スキル (`codex-review.md`) と同じパターンに揃え、依存を最小限に保つ。
