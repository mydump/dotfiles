# Dotfiles

Small Zsh and Vim configuration for Linux, macOS and FreeBSD.

## Installation

Prerequisites: Git to clone the repository, Zsh and Vim. Keep the cloned directory:
the installation creates symbolic links to it.

```sh
git clone https://github.com/mydump/dotfiles.git "$HOME/dotfiles"
cd "$HOME/dotfiles"
./install.sh
```

Optional flags (also usable together):

- `--install-packages`: install missing Zsh/Vim via apt-get on Debian-based Linux,
  Homebrew on macOS, or pkg on FreeBSD. The package manager must already exist.
  Package installation may ask for administrator authentication and confirmation.
  Other distributions: install the missing programs with your own package manager.
- `--replace`: delete conflicting `.zsh`, `.zshrc`, `.vim`, `.vimrc` files or
  directories and replace them with links. No backups. Also remove `.gvimrc` and
  `.tmux.conf`; remove `.zlogin` only if it matches the original repository version.
  Custom `.zlogin` files are kept with a notice. Installed programs are not removed.
- `--change-shell`: change only the current user's login shell to Zsh.

Fresh users are the intended use case. Without `--replace`, installation stops on existing conflicting files.
With `--replace`, those files are deleted without backups. Running it again keeps correct links.
Git, curl, language servers and development tools are not runtime requirements.

## Zsh

Colored file lists, case-insensitive completion, Emacs-style editing, command
history shared between sessions and a prompt with user, host, directory and Git
branch (when Git is installed). `*` means unstaged, `+` means staged changes.
Aliases: `ll`, `lh`, `...` (two directories up), `now` (Unix timestamp).
No forced locale or machine-specific development paths.

## Vim

Built-in syntax recognition, dark Smyck colors, line numbers, search highlighting,
visible trailing spaces and two-space soft tabs. Makefiles use real tabs.
No plugins or automatic whitespace removal. Ctrl+L clears search highlighting.
`EDITOR` and `VISUAL` are set to Vim by Zsh.

Recovery data is private to the user and stored centrally:

- `$XDG_CACHE_HOME/vim/swap` and `backup` (default `~/.cache/vim/`)
- `$XDG_STATE_HOME/vim/undo` (default `~/.local/state/vim/`)

Persistent undo is enabled when supported by Vim. These files may contain old
file contents; treat them as private data. GUI Vim and tmux are not configured.

## Updating and removal

On an old machine with this repository in `~/dotfiles`:

```sh
cd "$HOME/dotfiles"
git pull --ff-only
./install.sh --replace
```

If Git reports local changes, stop and review them before proceeding. Do not run
this installer with sudo; package installation requests privileges separately.
After migration, `git pull --ff-only` and a new terminal normally suffice.

Use `git pull --ff-only` inside the repository to update. To remove, delete only the four
symbolic links `~/.zsh`, `~/.zshrc`, `~/.vim`, `~/.vimrc`. Recovery data is retained.
