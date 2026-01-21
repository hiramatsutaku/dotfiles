# zsh

## peco キーバインド

| キー | 関数 | 説明 |
|------|------|------|
| `Ctrl+@` | `peco-cdr` | 最近訪れたディレクトリに移動 |
| `Ctrl+[` | `peco-git-checkout` | git ブランチを切り替え |
| `Ctrl+]` | `peco-github-src` | ghq で管理しているリポジトリに移動 |
| `Ctrl+r` | `peco-select-history` | コマンド履歴を検索 |
| `Ctrl+t` | `peco-git-worktree` | git worktree を切り替え |
| `Ctrl+g` | `peco-ghostty-switch` | Ghostty のウィンドウを切り替え |

## ファイル構成

```
zsh/
├── .zshrc           # メイン設定
└── .zsh/
    └── peco-sources/
        ├── cdr.zsh
        ├── git-checkout
        ├── git-worktree
        ├── github-src
        ├── select-history.zsh
        └── ghostty-switch.zsh
```
