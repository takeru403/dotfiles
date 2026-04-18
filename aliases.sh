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
alias ls="eza --icons --group-directories-first"
alias ll="eza -la --icons --git --group-directories-first"
alias la="eza -A --icons --group-directories-first"
alias l="eza -F --icons --group-directories-first"
alias lt="eza --tree --icons --level=2"
alias tree="tre"
alias ..="cd .."
alias ...="cd ../.."
alias ....="cd ../../.."

# ===============================
# 開発ユーティリティ
# ===============================
alias serve="python3 -m http.server 8000"
alias ports="lsof -i -P -n | grep LISTEN"
alias psg="ps aux | grep"
alias du="dust"
alias du1="dust -d 1"

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

# ===============================
# Obsidian
# ===============================
export OBSIDIAN_VAULT="$HOME/Documents/Obsidian Vault"

# 今日のデイリーノートを表示
obs-today() {
  local today=$(date +%Y-%m-%d)
  local file="$OBSIDIAN_VAULT/${today}.md"
  if [[ -f "$file" ]]; then
    if command -v bat &>/dev/null; then
      bat --style=plain --language=markdown "$file"
    else
      cat "$file"
    fi
  else
    echo "今日のノートがありません: $file"
    echo "作成しますか？ (y/N): "
    read -r response
    [[ "$response" =~ ^[Yy]$ ]] && echo "# ${today}\n\n" > "$file" && nvim "$file"
  fi
}

# fzf でノートを検索してbatでプレビュー・nvimで開く
obs-find() {
  local file
  local previewer='cat {}'
  command -v bat &>/dev/null && previewer='bat --style=plain --color=always --language=markdown {}'
  file=$(find "$OBSIDIAN_VAULT" -name "*.md" | fzf \
    --preview "$previewer" \
    --preview-window=right:60%)
  [[ -n "$file" ]] && nvim "$file"
}

# 今日のデイリーノートに1行追記
obs-append() {
  if [[ -z "$1" ]]; then
    echo "Usage: obs-append <メモ内容>"
    return 1
  fi
  local today=$(date +%Y-%m-%d)
  local file="$OBSIDIAN_VAULT/${today}.md"
  [[ ! -f "$file" ]] && echo "# ${today}\n" > "$file"
  echo "$1" >> "$file"
  echo "追記しました → $file"
}

# キーワードでノート内容を全文検索してfzfで選択
obs-grep() {
  if [[ -z "$1" ]]; then
    echo "Usage: obs-grep <keyword>"
    return 1
  fi
  local file
  local previewer='cat {}'
  command -v bat &>/dev/null && previewer='bat --style=plain --color=always --language=markdown {}'
  file=$(grep -rl "$1" "$OBSIDIAN_VAULT" --include="*.md" | fzf \
    --preview "$previewer" \
    --preview-window=right:60%)
  [[ -n "$file" ]] && nvim "$file"
}
