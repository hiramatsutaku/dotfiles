#!/usr/bin/env bash
# deny-check.sh - Claude Code PreToolUse hook
# --dangerously-skip-permissions 使用時でも危険なコマンドをブロックする
#
# 入力: stdin に PreToolUse フックの JSON（tool_input.command を含む）
# 出力: exit 0 = 許可, exit 2 = ブロック
set -euo pipefail

# スクリプトの実体パスを解決（シンボリックリンク対応）
SCRIPT_PATH="$0"
while [[ -L "$SCRIPT_PATH" ]]; do
  LINK_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"
  SCRIPT_PATH="$(readlink "$SCRIPT_PATH")"
  [[ "$SCRIPT_PATH" != /* ]] && SCRIPT_PATH="$LINK_DIR/$SCRIPT_PATH"
done
SCRIPT_DIR="$(cd "$(dirname "$SCRIPT_PATH")" && pwd)"

# settings.json のパス（スクリプトの親ディレクトリ）
SETTINGS_FILE="${SETTINGS_FILE:-$SCRIPT_DIR/../settings.json}"

# stdin から JSON を読み取り、コマンドを抽出
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# コマンドが空なら許可
[[ -z "$COMMAND" ]] && exit 0

# settings.json が存在しなければ許可
[[ ! -f "$SETTINGS_FILE" ]] && exit 0

# permissions.deny から Bash(...) パターンを抽出
PATTERNS=$(jq -r '
  .permissions.deny // [] | .[] |
  select(startswith("Bash(")) |
  sub("^Bash\\("; "") |
  sub("\\)$"; "")
' "$SETTINGS_FILE")

# パターンが無ければ許可
[[ -z "$PATTERNS" ]] && exit 0

# コマンドチェーンを分割（;, &&, || で区切る）して個別に検証
SUBCMDS=$(printf '%s' "$COMMAND" | sed -e 's/;/\n/g' -e 's/&&/\n/g' -e 's/||/\n/g')

while IFS= read -r subcmd; do
  # 前後の空白を除去
  subcmd=$(echo "$subcmd" | sed 's/^[[:space:]]*//;s/[[:space:]]*$//')
  [[ -z "$subcmd" ]] && continue

  while IFS= read -r pattern; do
    [[ -z "$pattern" ]] && continue
    # bash のグロブマッチング（ワイルドカード対応）
    # shellcheck disable=SC2053
    if [[ "$subcmd" == $pattern ]]; then
      echo "BLOCKED by deny-check: '$subcmd' matches pattern 'Bash($pattern)'" >&2
      exit 2
    fi
  done <<< "$PATTERNS"
done <<< "$SUBCMDS"

exit 0
