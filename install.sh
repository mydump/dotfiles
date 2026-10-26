#!/bin/sh
set -eu
install_packages=no
change_shell=no
replace=no
for arg do
  case "$arg" in
    --install-packages) install_packages=yes ;;
    --replace) replace=yes ;;
    --change-shell) change_shell=yes ;;
    *) echo "Usage: $0 [--install-packages] [--change-shell] [--replace]" >&2; exit 2 ;;
  esac
done
repo=$(CDPATH= cd -- "$(dirname -- "$0")" && pwd -P)
# Check all destinations before making changes.
for name in .zsh .zshrc .vim .vimrc; do
  target=$HOME/$name
  if [ -e "$target" ] || [ -L "$target" ]; then
    if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$repo/$name" ]; then
      if [ "$replace" = yes ]; then
        case "$repo/" in "$target/"*) echo "Repository is inside $target; move it first." >&2; exit 1 ;; esac
        continue
      fi
      echo "Conflict: $target already exists. Move it manually before installation." >&2
      exit 1
    fi
  fi
done
missing=''
for tool in zsh vim; do
  if ! command -v "$tool" >/dev/null 2>&1; then missing="$missing $tool"; fi
done
if [ -n "$missing" ] && [ "$install_packages" = yes ]; then
  case $(uname -s) in
    Linux) manager=apt-get ;;
    Darwin) manager=brew ;;
    FreeBSD) manager=pkg ;;
    *) manager='' ;;
  esac
  if [ -z "$manager" ] || ! command -v "$manager" >/dev/null 2>&1; then
    echo "No supported package manager available. Please install:$missing" >&2
    exit 1
  fi
  if [ "$manager" = brew ]; then
    brew install $missing
  elif [ "$(id -u)" -eq 0 ]; then
    "$manager" install $missing
  else
    if ! command -v sudo >/dev/null 2>&1; then
      echo "Please install as administrator:$missing" >&2; exit 1
    fi
    sudo "$manager" install $missing
  fi
fi
for tool in zsh vim; do
  if ! command -v "$tool" >/dev/null 2>&1; then
    echo "Missing: $tool. Install it manually or use --install-packages." >&2
    exit 1
  fi
done
for name in .zsh .zshrc .vim .vimrc; do
  target=$HOME/$name
  if [ "$replace" = yes ] && { [ -e "$target" ] || [ -L "$target" ]; }; then
    if [ ! -L "$target" ] || [ "$(readlink "$target")" != "$repo/$name" ]; then
      rm -rf -- "$target"
    fi
  fi
  if [ ! -L "$HOME/$name" ]; then ln -s "$repo/$name" "$HOME/$name"; fi
done
if [ "$replace" = yes ]; then
  # Remove obsolete files, not directories or their symlink destinations.
  for name in .gvimrc .tmux.conf; do
    if [ -f "$HOME/$name" ] || [ -L "$HOME/$name" ]; then rm -f -- "$HOME/$name"; fi
  done
  legacy_zlogin=$(cat <<'LEGACY_ZLOGIN'
source ~/.rvm/scripts/'rvm'

PATH=$PATH:$HOME/.rvm/bin # Add RVM to PATH for scripting
PATH=/usr/local/bin:$PATH
PATH=/usr/local/bin:/usr/local/sbin:$PATH
LEGACY_ZLOGIN
)
  if [ -f "$HOME/.zlogin" ] && [ "$(cat "$HOME/.zlogin")" = "$legacy_zlogin" ]; then
    rm -f -- "$HOME/.zlogin"
  elif [ -e "$HOME/.zlogin" ] || [ -L "$HOME/.zlogin" ]; then
    echo 'Kept custom ~/.zlogin; check it for old RVM or PATH settings.'
  fi
fi
if [ "$change_shell" = yes ]; then
  zsh_path=$(command -v zsh)
  if [ "${SHELL:-}" != "$zsh_path" ]; then
    if ! grep -Fx "$zsh_path" /etc/shells >/dev/null 2>&1; then
      echo "$zsh_path is not listed in /etc/shells. Ask your administrator to add it." >&2
      exit 1
    fi
    chsh -s "$zsh_path"
  fi
fi
echo 'Dotfiles installed. Open a new terminal; after a shell change, log in again.'
