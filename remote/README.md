# remote

ssh 先 macOS (Apple Silicon) を軽量に整えるためのサブセット。

## 適用手順

ssh 先で以下を実行する:

```sh
mkdir -p ~/src/github.com/hiramatsutaku
cd ~/src/github.com/hiramatsutaku
git clone https://github.com/hiramatsutaku/dotfiles.git
bash dotfiles/remote/bootstrap.sh
exec zsh -l
```

`bootstrap.sh` は冪等。何度実行しても壊れない。

## ローカル (`~/.zshrc`) との主な違い

| 項目 | ローカル | リモート |
|------|---------|---------|
| fuzzy finder | peco | fzf (`Ctrl-R` 履歴 / `Ctrl-T` ファイル) |
| ls 代替 | lsd | eza |
| GUI 寄りツール | sketchybar / borders / cask 多数 | なし |
| starship 設定 | `starship/starship.toml` | 同じものを symlink |
| ローカル差分 | `~/.zshrc.local` | `~/.zshrc.local` (同じ仕組み) |

## ファイル

- `Brewfile` — 最小 brew セット
- `zshrc.remote` — `~/.zshrc` の実体
- `bootstrap.sh` — セットアップ entry point

決定理由は [`../docs/decisions/005-remote-shell-setup.md`](../docs/decisions/005-remote-shell-setup.md) を参照。
