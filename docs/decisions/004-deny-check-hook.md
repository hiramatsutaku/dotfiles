# PreToolUse hook で危険なコマンドをブロック

`--dangerously-skip-permissions` 使用時でも破壊的コマンドを防ぐため、
`permissions.deny` パターンを PreToolUse hook (`deny-check.sh`) で検証する仕組みを導入した。

wasabeef.jp の記事 (https://wasabeef.jp/blog/claude-code-secure-bash) を参考にした。
