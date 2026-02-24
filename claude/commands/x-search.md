---
invocation: user
---

X (Twitter) 上の情報を xAI API の `x_search` ツールを使って検索・要約してください。

## 前提条件の確認

1. 環境変数 `$XAI_API_KEY` が設定されているか確認する
2. 未設定 → `export XAI_API_KEY=your-api-key` を案内して停止

## ワークフロー

### 1. 検索意図の把握

ユーザーの入力から以下を判断する:
- **検索クエリ**: 何について調べたいか
- **期間指定** (任意): `from_date`, `to_date` (ISO 8601 形式, e.g. `2025-01-01`)
- **アカウント指定** (任意): `allowed_x_handles` (特定アカウントに限定) / `excluded_x_handles` (除外)

### 2. xAI API にリクエスト

以下の curl コマンドで xAI API を呼び出す。`<PROMPT>` にはユーザーの検索意図を反映した日本語プロンプトを構築して埋め込む。

基本リクエスト (オプションなし):
```bash
curl -s https://api.x.ai/v1/responses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -d '{
    "model": "grok-4-1-fast-reasoning",
    "input": "<PROMPT>",
    "tools": [{"type": "x_search"}]
  }' | jq -r '.output[] | select(.content) | .content[] | select(.text) | .text'
```

期間・アカウント指定ありの場合:
```bash
curl -s https://api.x.ai/v1/responses \
  -H "Content-Type: application/json" \
  -H "Authorization: Bearer $XAI_API_KEY" \
  -d '{
    "model": "grok-4-1-fast-reasoning",
    "input": "<PROMPT>",
    "tools": [{"type": "x_search", "from_date": "<FROM>", "to_date": "<TO>", "allowed_x_handles": ["<HANDLE>"], "excluded_x_handles": ["<HANDLE>"]}]
  }' | jq -r '.output[] | select(.content) | .content[] | select(.text) | .text'
```

**プロンプト構築のガイドライン**:
- 検索トピックを明確に含める
- 「X上の最新の投稿を検索して」という指示を含める
- 多様な視点を収集するよう指示する
- 日本語で回答するよう指示する

### 3. 結果の提示

API レスポンスのテキストを以下のフォーマットで構造化して提示する。

## 出力フォーマット

### 検索結果サマリー
- 検索クエリ: (実際に使用したクエリ)
- 検索期間: (指定がある場合)
- 対象/除外アカウント: (指定がある場合)

### 主な発見
1. ポイント1
2. ポイント2
3. ...

### 注目の意見・視点
- **賛成/肯定的**: ...
- **反対/批判的**: ...
- **ユニークな視点**: ...

### 関連リンク・リソース
- (API レスポンスに含まれるリンクがあれば記載)
