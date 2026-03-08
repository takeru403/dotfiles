# ===============================
# .zshrc
# ===============================

# Dev Container 内では設定をスキップ
if grep -qE '/devcontainer|remote-containers' /proc/1/cgroup 2>/dev/null; then
  return
fi

# ===============================
# Powerlevel10k instant prompt
# ===============================
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

# ===============================
# Oh My Zsh
# ===============================
export ZSH="$HOME/.oh-my-zsh"
ZSH_DISABLE_COMPFIX=true
plugins=(
  git
  z
  web-search
  python
  zsh-syntax-highlighting
  zsh-autosuggestions
)
source $ZSH/oh-my-zsh.sh

# ===============================
# Homebrew
# ===============================
if [[ -d "/opt/homebrew" ]]; then
  export PATH="/opt/homebrew/bin:$PATH"
fi

# ===============================
# Powerlevel10k テーマ
# ===============================
POWERLEVEL9K_DISABLE_CONFIGURATION_WIZARD=true
source /opt/homebrew/share/powerlevel10k/powerlevel10k.zsh-theme
# [[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# ===============================
# pyenv
# ===============================
export PYENV_ROOT="$HOME/.pyenv"
export PATH="$PYENV_ROOT/bin:$PATH"
if command -v pyenv 1>/dev/null 2>&1; then
  eval "$(pyenv init --no-rehash -)"
fi
eval "$(pyenv virtualenv-init -)"
export PYENV_VIRTUALENV_DISABLE_PROMPT=1

# ===============================
# Node.js (NVM) - 遅延ロード
# ===============================
export NVM_DIR="$HOME/.nvm"
if [ -s "$NVM_DIR/nvm.sh" ]; then
  _nvm_load() {
    unset -f nvm node npm npx _nvm_load
    \. "$NVM_DIR/nvm.sh"
    [ -s "$NVM_DIR/bash_completion" ] && \. "$NVM_DIR/bash_completion"
  }
  nvm()  { _nvm_load; nvm  "$@"; }
  node() { _nvm_load; node "$@"; }
  npm()  { _nvm_load; npm  "$@"; }
  npx()  { _nvm_load; npx  "$@"; }
fi

# ===============================
# Volta (Node.js)
# ===============================
export VOLTA_HOME="$HOME/.volta"
export PATH="$VOLTA_HOME/bin:$PATH"

# ===============================
# aqua (CLI バージョン管理)
# ===============================
export PATH="$HOME/.aqua/bin:$PATH"
eval "$(aqua init -)"
export PATH="$(aqua root-dir)/bin:$PATH"

# ===============================
# Java
# ===============================
if [[ -d "/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home" ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
fi

# ===============================
# Conda（存在する場合のみ）
# ===============================
CONDA_PATH="$HOME/anaconda3"
if [[ -f "$CONDA_PATH/bin/conda" ]]; then
  __conda_setup="$('$CONDA_PATH/bin/conda' 'shell.zsh' 'hook' 2> /dev/null)"
  if [ $? -eq 0 ]; then
    eval "$__conda_setup"
  elif [ -f "$CONDA_PATH/etc/profile.d/conda.sh" ]; then
    . "$CONDA_PATH/etc/profile.d/conda.sh"
  else
    export PATH="$CONDA_PATH/bin:$PATH"
  fi
  unset __conda_setup
fi

# ===============================
# その他パス
# ===============================
export PATH="$HOME/.local/bin:$PATH"
export PATH="/opt/homebrew/opt/mysql@8.4/bin:$PATH"
export LDFLAGS="-L/usr/local/opt/zlib/lib"
export CPPFLAGS="-I/usr/local/opt/zlib/include"
export PKG_CONFIG_PATH="/usr/local/opt/zlib/lib/pkgconfig"

# ===============================
# Python
# ===============================
export PYTHONPATH="."
export PYTHON_COLORS=1

# ===============================
# エディタ
# ===============================
export EDITOR=vim
export VISUAL=vim

# ===============================
# Shell オプション
# ===============================
setopt no_beep
setopt hist_ignore_dups
setopt share_history
setopt inc_append_history
setopt auto_cd

export HISTFILE=~/.zsh_history
export HISTSIZE=100000
export SAVEHIST=100000

# ===============================
# 補完設定
# ===============================
fpath+=~/.zfunc
zstyle ':completion:*' menu select
zstyle ':completion:*:default' menu select=2
zstyle ':completion:*' list-colors "${LS_COLORS}"
zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'

# ===============================
# vi キーバインド
# ===============================
bindkey -v

# ===============================
# エイリアス
# ===============================
alias vi="nvim"
alias vim="nvim"
alias view="nvim -R"
alias zshconfig="vim ~/.zshrc"

alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gp="git push"
alias gl="git log --oneline"

alias cl="claude"
alias clc="claude --continue"
alias clr="claude --resume"
alias gm="gemini"

alias py="python3"
alias pip="pip3"

alias snowsql=/Applications/SnowSQL.app/Contents/MacOS/snowsql

# ===============================
# 共通エイリアスファイル
# ===============================
DOTFILES="${DOTFILES:-$HOME/ghq/github.com/takeru403/dotfiles}"
[[ -f "$DOTFILES/aliases.sh" ]] && source "$DOTFILES/aliases.sh"

# ===============================
# ghq + fzf でリポジトリ移動
# ===============================
function gq() {
  local dir=$(ghq list -p | fzf --query="$1")
  if [ -n "$dir" ]; then
    cd "$dir"
  fi
}

# ===============================
# ローカル設定（マシン固有の設定はこちらに）
# ===============================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
