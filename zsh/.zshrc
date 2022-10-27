#========================
# general
#========================

# ディレクトリ名の入力のみで移動する
setopt AUTO_CD

# $ cd -<TAB>
DIRSTACKSIZE=100
setopt AUTO_PUSHD
setopt PUSHD_IGNORE_DUPS

### Complement ###
# 補完機能を有効にする
autoload -Uz compinit; compinit
# メニュー選択モード
zstyle ':completion:*:default' menu select=2
# 補完時に大文字小文字を区別しない
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

### Color ###
autoload -Uz colors
colors

### Prompt ###
# show git branch name
function prompt-git-current-branch {
  local name st color

  name=`git symbolic-ref HEAD 2> /dev/null`
  if [[ -z $name ]]
  then
    return
  fi
  name=`basename $name`

  st=`git status 2> /dev/null`
  if [[ -n `echo "$st" | grep "^nothing to"` ]]; then
          color=${fg[white]}
  elif [[ -n `echo "$st" | grep "^nothing added"` ]]; then
          color=${fg[yellow]}
  elif [[ -n `echo "$st" | grep "^# Untracked"` ]]; then
          color=${fg_bold[red]}
  else
          color=${fg[red]}
  fi

  echo "%{$color%}($name)%{$reset_color%}"
}

# プロンプトが表示されるたびにプロンプト文字列を評価、置換する
setopt prompt_subst
PROMPT='`prompt-git-current-branch`%F{white}%F{magenta}%B%n%b%f@%F{yellow}%U%m%u%f:%F{green}%(3~,%-1~/.../%1~,%~)%f%# '
PROMPT2="%_%% "
SPROMPT="%r is correct? [n,y,a,e]: "
RPROMPT=""

### History ###
# ヒストリを保存するファイル
HISTFILE=~/.zsh_history
# メモリに保存されるヒストリの件数
HISTSIZE=100000
# 保存されるヒストリの件
SAVEHIST=100000
# マッチしたコマンドのヒストリを表示できるようにする
autoload history-search-end
zle -N history-beginning-search-backward-end history-search-end
zle -N history-beginning-search-forward-end history-search-end
bindkey "^P" history-beginning-search-backward-end
bindkey "^N" history-beginning-search-forward-end

# cdr
autoload -Uz is-at-least
if is-at-least 4.3.11
then
  autoload -Uz chpwd_recent_dirs cdr add-zsh-hook
  add-zsh-hook chpwd chpwd_recent_dirs
  zstyle ':chpwd:*' recent-dirs-max 1000
  zstyle ':chpwd:*' recent-dirs-default yes
  zstyle ':completion:*' recent-dirs-insert both
fi


#========================
# peco
#========================
# load peco sources
for f (~/.zsh/peco-sources/*) source "${f}"
bindkey '^@' peco-cdr
bindkey '^[' peco-git-checkout
bindkey '^]' peco-github-src
bindkey '^r' peco-select-history


#========================
# alias
#========================
alias ls="lsd -al"
alias cat="bat"
alias dv="git co develop"
alias pl="git pull"

# GitHub
# 現在のブランチの PR もしくは PR 作成画面をブラウザで開く
alias pr="gh pr view -w || gh pr create -w"

# ローカルの設定を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# MEMO: homebrew の設定は .zshrc.local に置いた
# # homebrew
# eval "$(/opt/homebrew/bin/brew shellenv)"

# direnv
eval "$(direnv hook zsh)"

# anyenv
eval "$(anyenv init -)"

# starship
eval "$(starship init zsh)"

# pyenv
PYENV_ROOT="${HOME}/.pyenv"
PATH="${PYENV_ROOT}/bin:${PATH}"
if command -v pyenv 1>/dev/null 2>&1; then
    eval "$(pyenv init --path)"
    eval "$(pyenv init -)"
fi

