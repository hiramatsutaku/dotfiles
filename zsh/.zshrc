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

# 単語の区切り文字を設定（backward-kill-word で "-" などで区切る）
WORDCHARS='*?[]~=&;!#$%^(){}<>-'

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
bindkey '^t' peco-git-worktree


#========================
# alias
#========================
alias ls="lsd -al"
alias cat="bat"
alias gbr="git branch"
alias gcm="git commit -m"
alias gco="git checkout"
alias gnew="git checkout -b"
alias gst="git status"
alias glo="git log --oneline"

alias gdv="git co develop"
alias gmn="git co main"
alias gpl="git pull"
alias dv="git co develop"
alias mn="git co main"
alias pl="git pull"

alias gpr="gh pr view -w || gh pr create -w"
alias pr="gh pr view -w || gh pr create -w"

# git-wt (git worktree wrapper)
alias gwb="git wt"
alias gwd="git wt -d"

# Claude Code プロファイル切り替え
# CLAUDE_CONFIG_DIR ごとに .claude.json・設定・Keychain の資格情報が分かれるので、
# プロファイルごとに 1 回 /login すれば以降は行き来しても再ログイン不要。
# 既定（CLAUDE_CONFIG_DIR 未設定 = ~/.claude）が仕事用アカウント。
# 注意: CLAUDE_CONFIG_DIR は絶対パス必須。セッション途中の変更は効かないので起動前に決める。
#       ディレクトリ名を変えると Keychain のサービス名（パスの sha256 由来）も変わり
#       再ログインが必要になるため、プロファイル名は決め打ちにする
CLAUDE_PROFILE_ROOT="$HOME/.claude-profiles"
CLAUDE_DOTFILES_DIR="$HOME/src/github.com/hiramatsutaku/dotfiles/claude"

# 新しいプロファイルを作る。dotfiles の設定を symlink で共有し、
# settings.json だけは dotfiles 版のコピーにする。dotfiles 版には会社の設定
# （OTEL など）を入れず claude/work/settings.work.json に分けている（docs/decisions/008）
claude-profile-create() {
  local name=$1
  if [[ -z $name ]]; then
    print -u2 "usage: claude-profile-create <name>"
    return 1
  fi
  local dir="$CLAUDE_PROFILE_ROOT/$name"
  if [[ -e $dir ]]; then
    print -u2 "claude-profile-create: already exists: $dir"
    return 1
  fi
  local dot=$CLAUDE_DOTFILES_DIR
  if [[ ! -d $dot ]]; then
    print -u2 "claude-profile-create: dotfiles not found: $dot"
    return 1
  fi
  mkdir -p "$dir" || return 1
  local item
  for item in rules skills commands scripts keybindings.json; do
    [[ -e "$dot/$item" ]] && ln -sfn "$dot/$item" "$dir/$item"
  done
  [[ -e "$HOME/.claude/CLAUDE.md" ]] && ln -sfn "$HOME/.claude/CLAUDE.md" "$dir/CLAUDE.md"
  # 念のため OTEL 系も落とす。dotfiles 版に紛れ込んでも、個人利用が会社の telemetry に乗らないようにする
  if [[ -f "$dot/settings.json" ]]; then
    jq '.env |= with_entries(select(.key | (startswith("OTEL_") or . == "CLAUDE_CODE_ENABLE_TELEMETRY") | not))' \
      "$dot/settings.json" > "$dir/settings.json" || return 1
  fi
  print "created: $dir"
  ls -1 "$dir" | sed 's/^/  /'
  print "次に: claude-profile $name で起動して /login"
}

claude-profile() {
  local name=$1
  if [[ -z $name ]]; then
    print -u2 "usage: claude-profile <name> [claude args...]"
    print -u2 "       claude-profile-create <name>   # 新規作成"
    print -u2 "profiles: $(ls -1 "$CLAUDE_PROFILE_ROOT" 2>/dev/null | tr '\n' ' ')"
    return 1
  fi
  local dir="$CLAUDE_PROFILE_ROOT/$name"
  if [[ ! -d $dir ]]; then
    print -u2 "claude-profile: no such profile: $name ($dir)"
    print -u2 "profiles: $(ls -1 "$CLAUDE_PROFILE_ROOT" 2>/dev/null | tr '\n' ' ')"
    print -u2 "作成するには: claude-profile-create $name"
    return 1
  fi
  shift
  CLAUDE_CONFIG_DIR="$dir" command claude "$@"
}

# プロファイル名を補完する（claude-profile / claude-profile-create の第 1 引数）
_claude_profile_names() {
  local -a names
  names=(${(f)"$(ls -1 "$CLAUDE_PROFILE_ROOT" 2>/dev/null)"})
  _describe 'profile' names
}
compdef _claude_profile_names claude-profile
compdef _claude_profile_names claude-profile-create

# ローカルの設定を読み込む
[ -f ~/.zshrc.local ] && source ~/.zshrc.local

# MEMO: homebrew の設定は .zshrc.local に置いた
# # homebrew
# eval "$(/opt/homebrew/bin/brew shellenv)"

# git-wt
eval "$(git-wt --init zsh)"

# direnv
eval "$(direnv hook zsh)"

# mise
eval "$(mise activate zsh)"

# starship
eval "$(starship init zsh)"

export PATH="/opt/homebrew/opt/libpq/bin:$PATH"
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"

# Added by CodeRabbit CLI installer
export PATH="/Users/hirataku/.local/bin:$PATH"

# pnpm
export PNPM_HOME="/Users/hirataku/Library/pnpm"
case ":$PATH:" in
  *":$PNPM_HOME:"*) ;;
  *) export PATH="$PNPM_HOME:$PATH" ;;
esac
# pnpm end
export PATH="/opt/homebrew/opt/mysql-client/bin:$PATH"
