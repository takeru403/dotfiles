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
  zsh-vi-mode
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
# aqua (CLI バージョン管理)
# ===============================
export PATH="$HOME/.aqua/bin:$PATH"
export PATH="$(aqua root-dir)/bin:$PATH"

# ===============================
# Java
# ===============================
if [[ -d "/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home" ]]; then
  export JAVA_HOME="/Library/Java/JavaVirtualMachines/adoptopenjdk-11.jdk/Contents/Home"
  export PATH="$JAVA_HOME/bin:$PATH"
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

alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --git --group-directories-first"
alias la="eza -A --icons --group-directories-first"
alias l="eza -F --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"
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
# tmux ラッパー（引数なし = 使い捨て、引数あり = そのまま）
# ===============================
function tmux() {
  if [[ $# -eq 0 ]]; then
    command tmux new-session -s "tmp_$$" \; set-option destroy-unattached on
  else
    command tmux "$@"
  fi
}

# ===============================
# ローカル設定（マシン固有の設定はこちらに）
# ===============================
[[ -f ~/.zshrc.local ]] && source ~/.zshrc.local
export PATH="$PATH:/Applications/Obsidian.app/Contents/MacOS"


tre() { command tre "$@" -e && source "/tmp/tre_aliases_$USER" 2>/dev/null; }
eval "$(zoxide init zsh --cmd cd)"


if command -v wt >/dev/null 2>&1; then eval "$(command wt config shell init zsh)"; fi
