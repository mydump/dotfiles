#!/bin/sh
set -eu
install_packages=yes
change_shell=yes
replace=no
for arg do
  case "$arg" in
    --install-packages) install_packages=yes ;;
    --no-install-packages) install_packages=no ;;
    --no-change-shell) change_shell=no ;;
    --replace) replace=yes ;;
    --change-shell) change_shell=yes ;;
    *) echo "Usage: $0 [--replace] [--no-install-packages] [--no-change-shell]" >&2; exit 2 ;;
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
    echo "Missing: $tool. Install it manually and rerun the installer." >&2
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
  account=$(id -un)
  # Read the account database: $SHELL can still contain the old login shell.
  case $(uname -s) in
    Darwin) current_shell=$(dscl . -read "/Users/$account" UserShell | awk '{print $2}') ;;
    Linux) current_shell=$(getent passwd "$account" | awk -F: '{print $7}') ;;
    FreeBSD) current_shell=$(pw usershow "$account" | awk -F: '{print $10}') ;;
    *) echo 'Cannot determine login shell on this platform.' >&2; exit 1 ;;
  esac
  if [ -z "$current_shell" ]; then
    echo "Cannot read login shell for $account." >&2; exit 1
  fi
  if [ "$current_shell" != "$zsh_path" ]; then
    if ! grep -Fx "$zsh_path" /etc/shells >/dev/null 2>&1; then
      echo "Registering $zsh_path in /etc/shells."
      if [ "$(id -u)" -eq 0 ]; then
        printf '%s\n' "$zsh_path" >> /etc/shells
      else
        printf '%s\n' "$zsh_path" | sudo tee -a /etc/shells >/dev/null
      fi
    fi
    chsh -s "$zsh_path" "$account"
    echo "Login shell changed to Zsh for $account."
  fi
fi
echo 'Dotfiles installed. Open a new terminal; after a shell change, log out and log in again.'
