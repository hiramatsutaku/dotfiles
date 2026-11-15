When you list GitHub pull requests, issues, branches, or commits for the user to open or act on, write each one as a full URL, not only its number or name.

- 番号だけ（`#123`、`other-repo#45`）や名前だけ（`feat/add-login`）で挙げない。`https://github.com/<owner>/<repo>/pull/<番号>` のように、押せばそのまま開ける URL で書く
- 別のリポジトリのものは、URL にリポジトリ名まで入れる。番号だけだと、今いるリポジトリの同じ番号に見える
- 対象は「マージしてほしい PR」「次に見てほしい issue」のように、ユーザーが開いて操作するものの一覧。同じ返事の中で既に URL を書いたものを文中で指すときは、番号だけでよい
- コミットメッセージ・PR の本文・issue のコメントの中は対象外。GitHub が `#番号` と `owner/repo#番号` をリンクにするので、そちらの書き方に従う
