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

   いずれの場合も**最強設定のフラグを必ず付ける**（グローバル config は日常対話用に low/fast のため、レビュー時のみ引き上げる）:

   ```bash
   codex review --base <デフォルトブランチ> \
     -c model_reasoning_effort="xhigh" \
     -c service_tier="default"
   ```

3. Codex の出力結果をそのまま表示

## 実行とタイムアウト

- `codex review` は**タイムアウト付き**で実行する（xhigh は推論が長いため目安 8〜12 分）。差分が大きい場合（多数ファイル・削除を含む cutover 等）は出力が出ないままハングすることがある。
- macOS には `timeout` コマンドが無い。バックグラウンド実行 + `( sleep N; kill -9 $PID )` のウォッチドッグ方式を使う。
- バックグラウンド実行 + ポーリング、または `timeout` 相当で上限を設けるのが安全。
- **指定時間内に出力が無ければタイムアウトとして扱う**:
  1. 残存プロセスを掃除する（`pkill -9 -f codex`。子プロセスが残ることがあるので PID 列挙して個別 kill すると確実）
  2. 「codex review はタイムアウトした」と明記し、**ブロックせず他の検証（ビルド/テスト/lint/actionlint 等）で代替**して先に進む
- レビュー後は**ブランチ・HEAD が変わっていないか確認**する（`codex review` が作業ブランチを別ブランチに checkout する場合がある）。変わっていたら復元する。

## 注意
- `codex review` は非対話的に実行される
- レビュー結果が長い場合でも省略せず全文を表示すること
