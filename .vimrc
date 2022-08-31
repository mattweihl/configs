set nocompatible
filetype plugin indent on
syntax on

"set rtp+=~/.vim/bundle/Vundle.vim
"
"call vundle#begin()
""call vundle#begin('~/some/path/here')
"
"Plugin 'VundleVim/Vundle.vim'
"Plugin 'file:///$HOME/configs/vim/vim-oscyank'
"
"call vundle#end()            
filetype plugin indent on    

runtime macros/matchit.vim

" colorscheme gruvbox 
" set background=light

nnoremap <esc><esc> :silent! nohls<cr>
set backspace=indent,eol,start
set hidden                    
set ruler                     
set wildmenu                  
set number 
set mouse=a
set hlsearch
set incsearch
set ignorecase
set smartcase
set autoindent
set shiftwidth=4
set softtabstop=4
set expandtab
set list
set listchars=tab:␉·
set clipboard=unnamed
"set cursorline
"set cursorcolumn
set nobackup
set history=1000
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx

" STATUS LINE ------------------------------------------------------------ {{{

" Clear status line when vimrc is reloaded.
set statusline=

" Status line left side.
set statusline+=\ %F\ %M\ %Y\ %R

" Use a divider to separate the left side from the right side.
set statusline+=%=

" Status line right side.
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%

" Show the status on the second to last line.
set laststatus=2

" }}}

packloadall

let g:prettier#autoformat = 1
let g:prettier#autoformat_require_pragma = 0

" yank operation don't need to use the *" register (system clipboard)
"set clipboard+=unnamedplus

" autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | OSCYankReg " | endif


