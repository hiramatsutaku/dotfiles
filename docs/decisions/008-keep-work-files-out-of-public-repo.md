# 会社用のファイルは public の dotfiles に入れず claude/work/ に分ける

このリポジトリは public なので、会社で使う設定やスクリプトは ignore 済みの `claude/work/` に置き、
commit 前に pre-commit フック（`.githooks/pre-commit`）で会社関連の文字列とトークンを止める。

- 置き場: 会社用のスクリプトは `claude/work/scripts/`、会社前提の mods は `claude/work/mods/`
  （別の directory marketplace `hiramatsutaku-work-mods` として登録する）。参照側は実体パスで登録し直す
- settings: `~/.claude/settings.json` は symlink ではない実ファイルで、既定プロファイル（仕事用アカウント）が使う。
  dotfiles の `claude/settings.json` には個人でも使う設定だけを入れ、会社の設定（telemetry の送信先と認証、
  会社の marketplace と plugins、autoMode の環境説明など）は `claude/work/settings.work.json` に分ける。
  dotfiles 版は live から手で取るスナップショットなので、取り直すときは work 側に分けたキーを落としてから入れる。
  会社の設定を戻すときは `jq -s '.[0] * .[1]' claude/settings.json claude/work/settings.work.json` で重ねる
- 検出パターン: 社名をフックに書くとそれ自体が public に出るので、パターンは repo の外の
  `~/.config/dotfiles/forbidden-patterns` に置く。フック側に持つのは秘密情報の形（Bearer トークンや API キー）だけ
- すでに push 済みだった会社関連のファイル（prompt-review のレポート、日報の launchd ジョブ）は追跡を外して ignore した。
  履歴の書き換えと force push は、元に戻せず他の worktree との整合も崩れるので見送った。秘密情報は履歴に入っていない
