set nocompatible
filetype plugin indent on
syntax on

runtime macros/matchit.vim

" Plugins
call plug#begin('~/configs/nvim/plugged')

Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}

call plug#end()

" Theme
colorscheme gabriel 
set termguicolors

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
set clipboard^=unnamed,unnamedplus
set nobackup
set history=1000
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set cursorline
set encoding=utf-8
set fileencoding=utf-8
set shortmess=FI

" Status Line
set statusline=
set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%=
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%
set laststatus=3

" Clipboard yanking setup
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

" Shortcuts
if !exists('*ReloadConfig')
    function! ReloadConfig()
        echo "Reloaded neovim configuration"
        source $MYVIMRC
    endfunction
endif
nmap <silent> <leader>rr :call ReloadConfig()<CR>
