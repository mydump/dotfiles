export ZSH="$HOME/.zsh"
for config_file in "$ZSH"/lib/*.zsh; do
  source "$config_file"
done
unset config_file

autoload -Uz compinit
compinit

if command -v vim >/dev/null 2>&1; then
  export EDITOR=vim
  export VISUAL=vim
fi
