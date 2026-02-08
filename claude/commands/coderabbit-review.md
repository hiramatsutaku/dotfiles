# CodeRabbit AI のPRレビューコメント確認

現在のブランチに関連するPRの CodeRabbit AI レビューコメントを取得し、要約してください。

## 手順

1. `gh pr view --json number,title,url --jq '.number'` で現在のブランチのPR番号を取得
2. 以下のコマンドでCodeRabbitのレビューコメントを取得:
   - PRコメント: `gh pr view --comments --json comments --jq '.comments[] | select(.author.login == "coderabbitai") | .body'`
   - レビューコメント: `gh api repos/{owner}/{repo}/pulls/{pr_number}/reviews --jq '.[] | select(.user.login == "coderabbitai[bot]") | .body'`
   - インラインコメント: `gh api repos/{owner}/{repo}/pulls/{pr_number}/comments --jq '.[] | select(.user.login == "coderabbitai[bot]") | {path, line, body}'`
3. 取得したコメントを整理して報告

## 出力形式

### PR情報
- PR番号、タイトル、URL

### サマリー
- CodeRabbitによる全体的な評価の要約

### 指摘事項
各指摘を以下の形式でリスト化:
- **ファイル名:行番号** - 指摘内容の要約
  - 重要度（Critical / Warning / Suggestion / Nitpick）
  - 対応が必要かどうかの判断

### 未対応の指摘
まだ対応されていない指摘があれば、優先度順にまとめる。
