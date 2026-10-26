autoload -Uz colors
colors
export LSCOLORS="Gxfxcxdxbxegedabagacad"
export LS_COLORS='di=34:ln=35:so=32:pi=33:ex=31'
if ls --color=auto -d . >/dev/null 2>&1; then
  alias ls='ls --color=auto'
else
  alias ls='ls -G'
fi
setopt auto_cd multios cdablevars
