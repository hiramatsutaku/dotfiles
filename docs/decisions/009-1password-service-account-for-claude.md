# Claude Code からの 1Password は Service Account 経由の opsa だけにする

素の `op` はデスクトップアプリ連携で動くので、一度承認するとアカウント全体（個人も仕事も）が Claude から見えてしまう。
そこで個人アカウントに Claude 専用の `claude-code` Vault と、その Vault の `read_items` だけを持つ
Service Account `claude-code-cli` を作った。Claude からは `zsh/.zshrc` の `opsa` 経由でだけ使わせる。
参考: https://zenn.dev/toshipon/articles/1password-service-account-for-claude-code

- Vault: Service Account は Personal / Private Vault に付けられないので、専用 Vault が必須。
  入れるのは Claude に見せてよいアイテムだけにする（銀行やカード、本番の認証情報は入れない）
- トークン: macOS Keychain のサービス名 `OP_SERVICE_ACCOUNT_TOKEN` に置き、`opsa` を呼ぶたびに渡す。
  常時 export すると素の `op` でも自分の Vault が見えなくなるため。期限は 90 日（`--expires-in 90d`）で、切れたら作り直す
- 作り方: Claude のセッションの外のターミナルで実行する（セッション内で `op` を承認すると Claude の Bash にも効くおそれがある）
  ```sh
  op vault create claude-code --account my.1password.com
  TOKEN=$(op service-account create claude-code-cli --account my.1password.com --vault claude-code:read_items --expires-in 90d --raw) && /usr/bin/security add-generic-password -a "$USER" -s OP_SERVICE_ACCOUNT_TOKEN -w "$TOKEN" -U && echo saved; unset TOKEN
  ```
  `saved` が出なければトークンを失っている。Web UI で Service Account を消して作り直す
- Claude 側のガード: `permissions.deny` に素の `op`（`command op` / `env op` / フルパスも）と
  `security find-generic-password` を入れた。`permissions.ask` に `opsa read` と `opsa item get`
  （間にグローバルオプションを挟んだ形も）を入れ、値を表示させる典型的な操作で確認が出るようにした。
  網羅はしていない。`opsa inject` の stdout 出力や `opsa run --no-masking` でも値は出せる。ここでは割り切っている
  （どのみち見えるのは `claude-code` Vault の中だけ）。`opsa` 自体は関数の中で xtrace を切り、トークンがトレースに出ないようにしている。
  deny-check フックが読むのは dotfiles の `claude/settings.json` だが、Claude Code 本体は live の `~/.claude/settings.json` と
  `~/.claude-profiles/*/settings.json` を読むので、同じルールを全部に入れる
- 限界: deny は `sh -c` などで回避できる補助にすぎない。Service Account が絞るのは `opsa` の範囲だけで、
  素の `op` は 1Password アプリの承認プロンプトでしか止まらない。Claude のセッション中に出た 1Password の承認プロンプトは承認しない
