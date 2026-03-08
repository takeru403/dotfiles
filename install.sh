#!/usr/bin/env bash
# install.sh
# dotfiles のシンボリックリンクを作成するセットアップスクリプト
# 既存ファイルは .backup サフィックスを付けてバックアップする

set -euo pipefail

DOTFILES="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
BACKUP_DIR="$HOME/.dotfiles_backup_$(date +%Y%m%d_%H%M%S)"

log()  { echo "[dotfiles] $*"; }
warn() { echo "[dotfiles] WARNING: $*" >&2; }

backup_and_link() {
  local src="$1"   # dotfiles リポジトリ内のパス
  local dst="$2"   # リンク先（ホームディレクトリ等）

  # 既にシンボリックリンクかつ正しいリンク先ならスキップ
  if [[ -L "$dst" && "$(readlink "$dst")" == "$src" ]]; then
    log "Already linked: $dst"
    return
  fi

  # 既存ファイル・ディレクトリはバックアップ
  if [[ -e "$dst" ]]; then
    mkdir -p "$BACKUP_DIR"
    mv "$dst" "$BACKUP_DIR/"
    log "Backed up: $dst -> $BACKUP_DIR/$(basename "$dst")"
  fi

  # 親ディレクトリが存在しない場合は作成
  mkdir -p "$(dirname "$dst")"

  ln -s "$src" "$dst"
  log "Linked: $dst -> $src"
}

# =============================
# Shell 設定
# =============================
backup_and_link "$DOTFILES/.zshrc"    "$HOME/.zshrc"
backup_and_link "$DOTFILES/.zprofile" "$HOME/.zprofile"
backup_and_link "$DOTFILES/.zshenv"   "$HOME/.zshenv"
backup_and_link "$DOTFILES/.bashrc"   "$HOME/.bashrc"

# =============================
# Git 設定
# =============================
backup_and_link "$DOTFILES/.gitconfig" "$HOME/.gitconfig"

# =============================
# tmux
# =============================
backup_and_link "$DOTFILES/.tmux.conf" "$HOME/.tmux.conf"

# =============================
# vim
# =============================
backup_and_link "$DOTFILES/.vimrc" "$HOME/.vimrc"

# =============================
# aqua
# =============================
backup_and_link "$DOTFILES/aqua.yaml" "$HOME/aqua.yaml"

# =============================
# Ghostty
# =============================
backup_and_link "$DOTFILES/config/ghostty" "$HOME/.config/ghostty"

# =============================
# Neovim
# =============================
backup_and_link "$DOTFILES/config/nvim" "$HOME/.config/nvim"

# =============================
# 完了メッセージ
# =============================
log ""
log "Setup complete!"
if [[ -d "$BACKUP_DIR" ]]; then
  log "Backups saved to: $BACKUP_DIR"
fi
log ""
log "Next steps:"
log "  1. Restart your shell or run: source ~/.zshrc"
log "  2. Launch nvim and run :Lazy sync to install plugins"
log "  3. Update ~/.gitconfig [user] section if needed"
