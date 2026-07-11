#!/usr/bin/env bash
# Noctalia v5 dotfiles installer
# Backs up any existing config, then symlinks these dotfiles into place.
# Review before running. Does NOT install packages — see the Dependencies
# section in README.md for that.

set -euo pipefail

REPO="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
STAMP="$(date +%Y%m%d_%H%M%S)"
BACKUP="$HOME/.dotfiles-backup-$STAMP"

say()  { printf '\033[38;2;157;210;192m==>\033[0m %s\n' "$1"; }   # mint
warn() { printf '\033[38;2;232;184;168m!! \033[0m %s\n' "$1"; }   # peach

# Move an existing path into the backup dir (if it exists and isn't already our symlink)
backup() {
  local target="$1"
  if [ -e "$target" ] && [ ! -L "$target" ]; then
    mkdir -p "$BACKUP$(dirname "${target#$HOME}")"
    mv "$target" "$BACKUP${target#$HOME}"
    warn "backed up ${target/#$HOME/~}  ->  ${BACKUP/#$HOME/~}"
  elif [ -L "$target" ]; then
    rm -f "$target"
  fi
}

link() {  # link <repo-relative-src> <abs-dest>
  local src="$REPO/$1" dest="$2"
  backup "$dest"
  mkdir -p "$(dirname "$dest")"
  ln -s "$src" "$dest"
  say "linked ${dest/#$HOME/~}"
}

say "Installing Noctalia v5 dotfiles from $REPO"
echo

# Hyprland (whole dir)
link "config/hypr"                 "$HOME/.config/hypr"

# Noctalia base config (config.toml layer). Live GUI settings.toml is left alone.
link "config/noctalia/config.toml" "$HOME/.config/noctalia/config.toml"

# Zsh
link "config/zsh/.zshrc"           "$HOME/.zshrc"
link "config/zsh/.p10k.zsh"        "$HOME/.p10k.zsh"

# Wallpapers (copied, not linked — you'll want to own/add to these)
mkdir -p "$HOME/Pictures/Wallpaper"
cp -n "$REPO"/wallpapers/*.jpg "$HOME/Pictures/Wallpaper/" 2>/dev/null || true
say "copied wallpapers -> ~/Pictures/Wallpaper"

echo
say "Done. Backup (if any): ${BACKUP/#$HOME/~}"
warn "Paths in config/noctalia/config.toml are hardcoded to /home/shifaz — adjust avatar_path / directories for your user."
warn "Reload with:  hyprctl reload   &&   noctalia msg config-reload   (or log out/in)"
