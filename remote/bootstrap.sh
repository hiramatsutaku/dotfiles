#!/usr/bin/env bash
# ssh 先 macOS (Apple Silicon) を最小構成でセットアップする冪等スクリプト。
# - Xcode Command Line Tools
# - Homebrew
# - remote/Brewfile に列挙したパッケージ
# - ~/.zshrc, ~/.config/starship.toml の symlink

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

# 5. login shell の確認 (chsh は手動)
current_shell="$(dscl . -read "/Users/$(whoami)" UserShell | awk '{print $2}')"
if [ "${current_shell}" != "/bin/zsh" ] && [ "${current_shell}" != "${BREW_PREFIX}/bin/zsh" ]; then
  echo "==> Login shell is ${current_shell}. To switch to zsh run:"
  echo "    chsh -s /bin/zsh"
fi

echo "==> Done. Open a new shell or run: exec zsh -l"
