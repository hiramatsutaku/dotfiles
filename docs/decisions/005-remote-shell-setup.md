# ssh 先 macOS 向けに remote/ サブセットを用意

ローカル `.zshrc` は peco キーバインドや sketchybar 等 GUI 寄り依存が多く、ssh 先 (rq-macstudino) にそのまま流用すると重い。
`remote/` 配下に最小 Brewfile・fzf ベースの軽量 zshrc・bootstrap スクリプトを置き、starship 設定はローカルと共通利用する。
