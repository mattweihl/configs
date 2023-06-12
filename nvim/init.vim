set nocompatible

filetype plugin indent on
syntax on

runtime macros/matchit.vim

" Plugins
call plug#begin()

Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'ryanoasis/vim-devicons'
Plug 'scrooloose/nerdtree'
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'github/copilot.vim'
Plug 'folke/tokyonight.nvim'
Plug 'jiangmiao/auto-pairs' 

Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
" CocInstall coc-json coc-tsserver coc-eslint
Plug 'lewis6991/gitsigns.nvim'
Plug 'nvim-tree/nvim-web-devicons'
Plug 'romgrk/barbar.nvim'

Plug 'sheerun/vim-polyglot'


call plug#end()

inoremap jk <ESC>
nmap <C-n> :NERDTreeToggle<CR>
nmap <C-s> :w<CR>
nmap <C-w> :q<CR>

set background=dark
colorscheme tokyonight-night

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
set shiftwidth=2
set softtabstop=2
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
set smarttab

set statusline=
set statusline+=\ %F\ %M\ %Y\ %R
set statusline+=%=
set statusline+=\ ascii:\ %b\ hex:\ 0x%B\ row:\ %l\ col:\ %c\ percent:\ %p%%
set laststatus=3

autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankRegister"' | endif

if !exists('*ReloadConfig')
    function! ReloadConfig()
        echohl WarningMsg
        echom "Reloaded configuration"
        echohl None
        sleep 1
        source $MYVIMRC
    endfunction
endif
nmap <silent> <leader>rr :call ReloadConfig()<CR>


nmap <silent> <leader>q :q!<CR>
nmap <silent> <leader>qq :qa!<CR>
nmap <silent> <leader>wq :wqa!<CR>
nmap <silent> <leader>ww :w!<CR>

function! StartUp()
    if 0 == argc()
        NERDTree
    end
endfunction

autocmd VimEnter * call StartUp()

" use <tab> to trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
