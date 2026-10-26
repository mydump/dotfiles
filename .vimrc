set nocompatible
syntax enable
filetype plugin indent on
silent! colorscheme smyck
set background=dark
set number ruler cursorline
set nowrap
set expandtab tabstop=2 softtabstop=2 shiftwidth=2
set backspace=indent,eol,start
set incsearch hlsearch
set list listchars=tab:>-,trail:.
set laststatus=2
set statusline=%f\ %m%r%h%w%=%y\ %l:%c\ %p%%
set nofoldenable
nnoremap <silent> <C-l> :nohlsearch<CR><C-l>

" Keep recovery files away from edited documents; honor XDG overrides.
let s:cache = empty($XDG_CACHE_HOME) ? expand('~/.cache') : $XDG_CACHE_HOME
let s:state = empty($XDG_STATE_HOME) ? expand('~/.local/state') : $XDG_STATE_HOME
for s:dir in [s:cache . '/vim/swap', s:cache . '/vim/backup', s:state . '/vim/undo']
  call mkdir(s:dir, 'p', 0700)
endfor
let &directory = s:cache . '/vim/swap//'
let &backupdir = s:cache . '/vim/backup//'
set swapfile backup writebackup
if has('persistent_undo')
  let &undodir = s:state . '/vim/undo//'
  set undofile
endif
augroup dotfiles
  autocmd!
  autocmd FileType make setlocal noexpandtab tabstop=8 softtabstop=0 shiftwidth=8
augroup END
