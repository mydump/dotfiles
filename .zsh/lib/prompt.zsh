autoload -Uz vcs_info add-zsh-hook
zstyle ':vcs_info:*' enable git
zstyle ':vcs_info:*' check-for-changes true
zstyle ':vcs_info:*' unstagedstr '*'
zstyle ':vcs_info:*' stagedstr '+'
zstyle ':vcs_info:*' formats ':%b%c%u'
_dotfiles_vcs_info() {
  vcs_info_msg_0_=''
  if (( $+commands[git] )); then
    vcs_info
  fi
}
add-zsh-hook precmd _dotfiles_vcs_info
setopt prompt_subst
PROMPT='[%n@%m %~${vcs_info_msg_0_}] %# '
