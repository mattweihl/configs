set nocompatible

filetype plugin indent on
syntax on

runtime macros/matchit.vim

" Plugins
call plug#begin('~/configs/nvim/plugged')

Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'ryanoasis/vim-devicons'
Plug 'morhetz/gruvbox'
Plug 'scrooloose/nerdtree'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'embark-theme/vim', { 'as': 'embark', 'branch': 'main' }
Plug 'APZelos/blamer.nvim'

call plug#end()

let g:blamer_enabled = 1
let g:blamer_show_in_insert_modes = 0
let g:blamer_show_in_visual_modes = 0

inoremap jk <ESC>
nmap <C-n> :NERDTreeToggle<CR>
nmap <C-s> :w<CR>
nmap <C-w> :q<CR>

" Start NERDTree and leave the cursor in it.
" autocmd VimEnter * NERDTree

" Theme
colorscheme embark
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
set smarttab

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

nmap <silent> <leader>q :q!<CR>
nmap <silent> <leader>qq :qa!<CR>
nmap <silent> <leader>wq :wqa!<CR>
nmap <silent> <leader>ww :w!<CR>

" coc config
let g:coc_global_extensions = [
  \ 'coc-snippets',
  \ 'coc-pairs',
  \ 'coc-tsserver',
  \ 'coc-eslint', 
  \ 'coc-prettier', 
  \ 'coc-json', 
  \ 'coc-pyright',
  \ 'coc-terminal',
  \ ]

" use <tab> for trigger completion and navigate to the next complete item
function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

inoremap <silent><expr> <Tab>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()

function! s:check_back_space() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

let g:coc_snippet_next = '<tab>'

" Use <c-space> to trigger completion.
inoremap <silent><expr> <c-space> coc#refresh()

" Remap for rename current word
nmap <F2> <Plug>(coc-rename)

" Highlight symbol under cursor on CursorHold
autocmd CursorHold * silent call CocActionAsync('highlight')

" Remap keys for gotos
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Remap for format selected region
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

" Find symbol of current document
nnoremap <silent> <space>o  :<C-u>CocList outline<cr>

lua << EOF
require('telescope').setup({
  defaults = {
    mappings = { i = { ['<esc>'] = require('telescope.actions').close } },
    borderchars = { '─', '│', '─', '│', '┌', '┐', '┘', '└' },
    file_ignore_patterns = { 'node_modules', '.git', 'build', 'node-offline-mirror' },
  },
})
EOF

nmap <silent> <leader>ff :Telescope find_files<CR>
nmap <silent> <leader>fg :Telescope live_grep<CR>

let g:NERDTreeShowHidden=1
