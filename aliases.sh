#!/usr/bin/env bash
# aliases.sh
# 共通エイリアス・関数集
# 使用方法: source ~/ghq/github.com/takeru403/dotfiles/aliases.sh

# ===============================
# AI ツール
# ===============================
alias cl="claude"
alias clc="claude --continue"
alias clr="claude --resume"
alias cli="claude --init"
alias gm="gemini"
alias gmp="gemini --prompt"

# ===============================
# Git
# ===============================
alias gs="git status"
alias ga="git add"
alias gaa="git add -A"
alias gc="git commit"
alias gcm="git commit -m"
alias gp="git push"
alias gpl="git pull"
alias gl="git log --oneline"
alias gd="git diff"
alias gb="git branch"
alias gco="git checkout"
alias gcb="git checkout -b"

# GitHub CLI
alias ghpr="gh pr create"
alias ghpv="gh pr view"
alias ghi="gh issue create"

# ===============================
# Node.js / NPM
# ===============================
alias ni="npm install"
alias ns="npm start"
alias nb="npm run build"
alias nd="npm run dev"
alias nt="npm test"

# Yarn
alias yi="yarn install"
alias ys="yarn start"
alias yb="yarn build"
alias yd="yarn dev"

# ===============================
# Python
# ===============================
alias py="python3"
alias pip="pip3"
alias venv="python3 -m venv"
alias activate="source venv/bin/activate"

# Poetry
alias poetry-shell="poetry shell"
alias poetry-install="poetry install"
alias poetry-add="poetry add"

# ===============================
# ファイル / ディレクトリ操作
# ===============================
alias ll="ls -la"
alias la="ls -A"
alias l="ls -CF"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ===============================
# 開発ユーティリティ
# ===============================
alias serve="python3 -m http.server 8000"
alias ports="lsof -i -P -n | grep LISTEN"
alias psg="ps aux | grep"
alias du1="du -h -d 1"

# Docker
alias d="docker"
alias dc="docker-compose"
alias dps="docker ps"
alias di="docker images"

# ===============================
# macOS 固有
# ===============================
if [[ "$OSTYPE" == "darwin"* ]]; then
  alias finder="open ."
  alias battery="pmset -g batt"
  alias weather="curl wttr.in/Tokyo"
  alias myip="curl ipinfo.io/ip"
fi

# ===============================
# 関数
# ===============================

# 新規プロジェクト作成
new_project() {
  if [ -z "$1" ]; then
    echo "Usage: new_project <project-name>"
    return 1
  fi
  mkdir "$1" && cd "$1"
  git init
  echo "# $1" > README.md
  echo "Created new project: $1"
  read -p "Start Claude Code? (y/N): " response
  if [[ "$response" =~ ^[Yy]$ ]]; then
    claude --init
    claude
  fi
}

# プロジェクト統計
project_stats() {
  echo "=== Project Stats ==="
  echo "Files:   $(find . -type f | wc -l)"
  echo "Commits: $(git rev-list --all --count 2>/dev/null || echo '0')"
  echo "Last:    $(git log -1 --format=%cd 2>/dev/null || echo 'N/A')"
}
