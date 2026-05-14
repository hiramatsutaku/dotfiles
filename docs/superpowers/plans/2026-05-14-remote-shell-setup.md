# Remote Shell Setup Implementation Plan

> **For agentic workers:** REQUIRED SUB-SKILL: Use superpowers:subagent-driven-development (recommended) or superpowers:executing-plans to implement this plan task-by-task. Steps use checkbox (`- [ ]`) syntax for tracking.

**Goal:** ssh 先 macOS (rq-macstudionoMac-Studio.local / Apple Silicon) を軽量・冪等に整えるための `remote/` サブセットを dotfiles リポに追加する。

**Architecture:** 既存 dotfiles 構造（ツール単位ディレクトリ + `~/.zshrc.local` で差分吸収）を踏襲し、`remote/` 配下に Brewfile・軽量 zshrc・bootstrap スクリプト・README を置く。starship 設定はローカルと共有（`starship/starship.toml` を symlink）。決定記録は `docs/decisions/005-remote-shell-setup.md` に既に追加済み。

**Tech Stack:** bash, zsh, Homebrew (brew bundle), starship, fzf, zsh-autosuggestions, zsh-syntax-highlighting, eza, bat, ripgrep, fd, gh

---

## File Structure

新規追加するファイル:

- `remote/Brewfile` — リモート用最小 brew セット
- `remote/zshrc.remote` — peco 抜き / fzf 入りの軽量 zshrc
- `remote/bootstrap.sh` — ssh 先で 1 発実行する冪等セットアップスクリプト
- `remote/README.md` — 適用手順とローカルとの差分の説明

既に追加済み:

- `docs/decisions/005-remote-shell-setup.md` — DR

共有利用（リンク先・改変なし）:

- `starship/starship.toml` — `${HOME}/.config/starship.toml` として symlink

---

## Task 1: `remote/Brewfile` を作成

**Files:**
- Create: `remote/Brewfile`

- [ ] **Step 1: ファイルを作成**

`remote/Brewfile` を以下の内容で作成する:

```ruby
# tap
tap 'homebrew/bundle'

# prompt & shell plugins
brew 'starship'
brew 'zsh-autosuggestions'
brew 'zsh-syntax-highlighting'

# fuzzy finder
brew 'fzf'

# modern CLI replacements
brew 'eza'
brew 'bat'
brew 'ripgrep'
brew 'fd'

# git / GitHub
brew 'git'
brew 'gh'
```

- [ ] **Step 2: ローカルで brew bundle のドライランで構文確認**

Run: `brew bundle check --file=/Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/Brewfile --no-upgrade`

Expected: ローカルには既に多くが入っているため "The Brewfile's dependencies are satisfied." と出るか、未インストール項目が列挙される（どちらでも Brewfile の構文エラーがないことが確認できれば OK）。

---

## Task 2: `remote/zshrc.remote` を作成

**Files:**
- Create: `remote/zshrc.remote`

- [ ] **Step 1: ファイルを作成**

`remote/zshrc.remote` を以下の内容で作成する:

```sh
#========================
# general
#========================
setopt AUTO_CD
DIRSTACKSIZE=100
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

### Complement ###
autoload -Uz compinit; compinit
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

### Color ###
autoload -Uz colors
colors

#========================
# history
#========================
HISTFILE=~/.zsh_history
HISTSIZE=100000
SAVEHIST=100000
setopt SHARE_HISTORY
setopt HIST_IGNORE_ALL_DUPS
setopt HIST_REDUCE_BLANKS

autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# cdr
autoload -Uz is-at-least
if is-at-least 4.3.11; then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 1000
  zstyle ':chpwd:*' recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi

#========================
# homebrew (Apple Silicon)
#========================
eval "$(/opt/homebrew/bin/brew shellenv)"

#========================
# zsh plugins (must be sourced before fzf for syntax-highlighting compatibility)
#========================
[ -f /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh ] && \
  source /opt/homebrew/share/zsh-autosuggestions/zsh-autosuggestions.zsh
[ -f /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh ] && \
  source /opt/homebrew/share/zsh-syntax-highlighting/zsh-syntax-highlighting.zsh

#========================
# fzf
#========================
[ -f /opt/homebrew/opt/fzf/shell/key-bindings.zsh ] && \
  source /opt/homebrew/opt/fzf/shell/key-bindings.zsh
[ -f /opt/homebrew/opt/fzf/shell/completion.zsh ] && \
  source /opt/homebrew/opt/fzf/shell/completion.zsh

#========================
# alias
#========================
alias ls="eza -al --git --icons=never"
alias ll="eza -l --git --icons=never"
alias tree="eza --tree --icons=never"
alias cat="bat"
alias gbr="git branch"
alias gcm="git commit -m"
alias gco="git checkout"
alias gnew="git checkout -b"
alias gst="git status"
alias glo="git log --oneline"
alias gdv="git checkout develop"
alias gmn="git checkout main"
alias gpl="git pull"
alias gpr="gh pr view -w || gh pr create -w"

#========================
# starship
#========================
eval "$(starship init zsh)"

# ローカル固有の設定 (PATH 追加など) は ~/.zshrc.local に書く
[ -f ~/.zshrc.local ] && source ~/.zshrc.local
```

- [ ] **Step 2: zsh の構文チェック**

Run: `zsh -n /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/zshrc.remote`

Expected: 何も出力されない（構文 OK）。エラーがあれば該当行を修正。

---

## Task 3: `remote/bootstrap.sh` を作成

**Files:**
- Create: `remote/bootstrap.sh`

- [ ] **Step 1: ファイルを作成**

`remote/bootstrap.sh` を以下の内容で作成する:

```sh
#!/usr/bin/env bash
# ssh 先 macOS (Apple Silicon) を最小構成でセットアップする冪等スクリプト。
# - Xcode Command Line Tools
# - Homebrew
# - remote/Brewfile に列挙したパッケージ
# - ~/.zshrc, ~/.config/starship.toml の symlink
#
# 何度実行しても壊れないように作る。

set -euo pipefail

DOTFILES_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
BREW_PREFIX="/opt/homebrew"

echo "==> dotfiles: ${DOTFILES_DIR}"

# 1. Xcode Command Line Tools
if ! xcode-select -p >/dev/null 2>&1; then
  echo "==> Installing Xcode Command Line Tools"
  echo "    GUI ダイアログが出たら同意してください"
  xcode-select --install || true
  echo "==> CLT のインストール完了を待ってから再度このスクリプトを実行してください"
  exit 1
fi

# 2. Homebrew
if [ ! -x "${BREW_PREFIX}/bin/brew" ]; then
  echo "==> Installing Homebrew"
  /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
fi
eval "$(${BREW_PREFIX}/bin/brew shellenv)"

# 3. brew bundle (冪等 — 既存パッケージはスキップ)
echo "==> brew bundle"
brew bundle --file="${DOTFILES_DIR}/remote/Brewfile"

# 4. symlinks (-f で上書き、-n で symlink 先がディレクトリでも追従しない)
echo "==> Linking dotfiles"
mkdir -p "${HOME}/.config"
ln -sfn "${DOTFILES_DIR}/remote/zshrc.remote" "${HOME}/.zshrc"
ln -sfn "${DOTFILES_DIR}/starship/starship.toml" "${HOME}/.config/starship.toml"

# 5. login shell が zsh でなければ案内 (chsh は手動)
current_shell="$(dscl . -read "/Users/$(whoami)" UserShell | awk '{print $2}')"
if [ "${current_shell}" != "/bin/zsh" ] && [ "${current_shell}" != "${BREW_PREFIX}/bin/zsh" ]; then
  echo "==> Login shell is ${current_shell}. To switch to zsh run:"
  echo "    chsh -s /bin/zsh"
fi

echo "==> Done. Open a new shell or run: exec zsh -l"
```

- [ ] **Step 2: 実行権限を付与**

Run: `chmod +x /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/bootstrap.sh`

Expected: エラーなし。`ls -l` で `rwxr-xr-x` を確認。

- [ ] **Step 3: bash の構文チェック**

Run: `bash -n /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/bootstrap.sh`

Expected: 何も出力されない（構文 OK）。

- [ ] **Step 4 (optional): shellcheck**

Run: `shellcheck /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/bootstrap.sh`

Expected: warning は許容、error は修正。shellcheck が入ってなければ Step 3 で十分。

---

## Task 4: `remote/README.md` を作成

**Files:**
- Create: `remote/README.md`

- [ ] **Step 1: ファイルを作成**

`remote/README.md` を以下の内容で作成する:

````markdown
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

決定理由は [`docs/decisions/005-remote-shell-setup.md`](../docs/decisions/005-remote-shell-setup.md) を参照。
````

---

## Task 5: ローカルでの最終検証

**Files:** （変更なし、検証のみ）

- [ ] **Step 1: 構文チェックをまとめて流す**

Run:

```sh
cd /Users/hirataku/src/github.com/hiramatsutaku/dotfiles
bash -n remote/bootstrap.sh && \
zsh -n remote/zshrc.remote && \
echo "syntax: OK"
```

Expected: `syntax: OK`

- [ ] **Step 2: ファイル一覧と権限を確認**

Run: `ls -la /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/remote/`

Expected: 4 ファイル (`Brewfile`, `README.md`, `bootstrap.sh`, `zshrc.remote`)。`bootstrap.sh` のみ実行ビット (`x`) が立っている。

- [ ] **Step 3: starship.toml のリンクが想定通り効くかチェック (空走)**

Run:

```sh
ls -la /Users/hirataku/src/github.com/hiramatsutaku/dotfiles/starship/starship.toml
```

Expected: ファイルが存在する。`bootstrap.sh` が ssh 先で `${DOTFILES_DIR}/starship/starship.toml` を symlink するので、リポをまるごと clone する前提でこのパスがリポ内に存在することが重要。

---

## Task 6: commit & push

**Files:** 全ての新規追加ファイル

- [ ] **Step 1: 変更内容を確認**

Run:

```sh
cd /Users/hirataku/src/github.com/hiramatsutaku/dotfiles
git status
```

Expected: untracked として `remote/` と `docs/decisions/005-remote-shell-setup.md` と `docs/superpowers/plans/2026-05-14-remote-shell-setup.md` が出る。

- [ ] **Step 2: 差分を眺める**

Run: `git diff --stat` と `git status` で過不足を確認。意図しないファイルが混ざってないか確認。

- [ ] **Step 3: ステージング**

Run:

```sh
git add remote/ docs/decisions/005-remote-shell-setup.md docs/superpowers/plans/2026-05-14-remote-shell-setup.md
```

- [ ] **Step 4: コミット**

Run:

```sh
git commit -m "$(cat <<'EOF'
Add remote/ subset for ssh-target macOS setup

Provide a lightweight remote shell setup (Brewfile + zshrc + bootstrap)
to bring ssh-target Macs in line with a minimal version of the local
environment without GUI tooling or peco dependencies. See
docs/decisions/005-remote-shell-setup.md for rationale.

Co-Authored-By: Claude Opus 4.7 (1M context) <noreply@anthropic.com>
EOF
)"
```

- [ ] **Step 5: push**

Run: `git push`

Expected: GitHub に反映される。ssh 先からは `git clone https://github.com/hiramatsutaku/dotfiles.git` で取得可能になる。

---

## Task 7: ssh 先での実行 (ユーザー手動)

これはユーザーが実機で行う。Claude 側からは ssh しない。

- [ ] **Step 1: ssh して bootstrap を実行**

```sh
ssh taku@rq-macstudionoMac-Studio.local
mkdir -p ~/src/github.com/hiramatsutaku && cd ~/src/github.com/hiramatsutaku
git clone https://github.com/hiramatsutaku/dotfiles.git
bash dotfiles/remote/bootstrap.sh
exec zsh -l
```

- [ ] **Step 2: 確認**

新しい zsh ログインで:
- starship のプロンプトが表示される
- `Ctrl-R` で fzf 履歴検索が起動する
- `ls` で eza が起動する
- `cat` で bat が起動する

期待通りでなければ、不足分を `Brewfile` か `zshrc.remote` に追記し、Task 5〜6 を繰り返す。

---

## Self-Review

- **Spec coverage:** DR (005) と上記の各タスクで、Brewfile / zshrc / bootstrap / README / starship 共通利用 / DR 追加が全てカバーされている
- **Placeholder scan:** TBD / TODO なし。全コード片を具体的に記述済み
- **Type consistency:** `BREW_PREFIX="/opt/homebrew"` と zshrc 内の `/opt/homebrew/...` パスが一致。Brewfile のパッケージ名と zshrc 内 source パスが一致（`zsh-autosuggestions/zsh-autosuggestions.zsh` 等は Homebrew formula のインストール先慣例どおり）
