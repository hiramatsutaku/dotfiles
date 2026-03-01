# CodeRabbit レビューコメント対応

現在のブランチに関連するPRの CodeRabbit AI レビューコメントを取得し、各指摘に対応してください。

## 手順

### 1. PR情報の取得

```sh
gh pr view --json number,title,url,headRepository
```

owner/repo は `gh repo view --json nameWithOwner --jq '.nameWithOwner'` で取得する。

### 2. CodeRabbit のレビューコメントを取得

インラインレビューコメント（コード行に対する指摘）を取得:

```sh
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments \
  --jq '.[] | select(.user.login == "coderabbitai[bot]") | {id, path, line, diff_hunk, body, in_reply_to_id}'
```

### 3. 各コメントの分析と対応

取得したコメントのうち、スレッドの起点（`in_reply_to_id` が null）のものを対象に、1件ずつ以下を判断:

#### 対応が必要な場合
1. 指摘内容を理解し、該当ファイル・行を修正する
2. 修正をコミットする（コミットメッセージに指摘内容を簡潔に含める）
3. コミットハッシュを取得し、CodeRabbit のコメントスレッドに返信:

```sh
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="対応しました: {コミットハッシュ(short)}

{修正内容の簡潔な説明}"
```

#### 対応不要な場合
CodeRabbit のコメントスレッドに、対応不要と判断した理由を返信:

```sh
gh api repos/{owner}/{repo}/pulls/{pr_number}/comments/{comment_id}/replies \
  -f body="対応不要と判断しました。

{理由の説明}"
```

### 4. 変更のプッシュ

すべてのコメントを処理した後、修正コミットがあればプッシュする:

```sh
git push
```

## 判断基準

以下の場合は **対応する**:
- バグやロジックエラーの指摘
- セキュリティリスクの指摘
- 明らかなコードスタイル違反
- 有用なリファクタリング提案

以下の場合は **対応不要**:
- 意図的な実装に対する提案で、現状が妥当な場合
- プロジェクトの規約・方針と合わない提案
- 過度な抽象化や複雑化を招く提案
- 既に別の方法で対処済みの指摘

## 注意事項

- 各コメントへの返信は必ず行うこと（対応/対応不要どちらの場合も）
- コミットは指摘ごとに分けること（まとめない）
- 既に返信済みのコメント（スレッドに自分の返信がある）はスキップする
- 対応に迷う場合はユーザーに確認を取ること
