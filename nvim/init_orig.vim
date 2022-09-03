set nocompatible
filetype plugin indent on
syntax on

runtime macros/matchit.vim

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

" Plugins
call plug#begin()

"Plug 'kyazdani42/nvim-web-devicons' 
"Plug 'kyazdani42/nvim-tree.lua'
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim', { 'tag': '0.1.0' }
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'sheerun/vim-polyglot'
Plug 'voldikss/vim-floaterm'
Plug 'neoclide/coc.nvim', {'branch': 'release'}
Plug 'tpope/vim-fugitive'


call plug#end()

" Clipboard yanking setup
autocmd TextYankPost * if v:event.operator is 'y' && v:event.regname is '' | execute 'OSCYankReg "' | endif

" Shortcuts
nnoremap <esc><esc> :silent! nohls<cr>
nmap <silent> <leader>ff :Telescope find_files<CR>
nmap <silent> <leader>fg :Telescope live_grep<CR>

if !exists('*ReloadConfig')
    function! ReloadConfig()
        echo "RELOADED VIM CONFIG"
        source $MYVIMRC
    endfunction
endif

nmap <silent> <leader>rr :call ReloadConfig()<CR>
nmap <silent> <leader>nn :CocCommand explorer<CR>

" Floatterm settings 
let g:floaterm_shell = 'NEOVIM=1 '.&shell
let g:floaterm_height = 0.25
let g:floaterm_autoclose = 1
let g:floaterm_wintype = 'split'
let g:floaterm_position = 'botright'
let g:floaterm_keymap_toggle = '<leader>tt'

" autocmd User CocNvimInit :CocCommand explorer

nmap <silent> <leader>qq :qa!<CR>
nmap <silent> <leader>q :wqa!<CR>

let g:currentmode={
  \ 'n': 'Normal',
  \ 'no': 'Normal·Operator Pending',
  \ 'v': 'Visual',
  \ 'V': 'Visual Line',
  \ '^V': 'Visual Block',
  \ 's': 'Select',
  \ 'S': 'S Line',
  \ '^S': 'S Block',
  \ 'i': 'Insert',
  \ 'R': 'Replace',
  \ 'Rv': 'V Replace',
  \ 'c': 'Command',
  \ 'cv': 'Vim Ex',
  \ 'ce': 'Ex',
  \ 'r': 'Prompt',
  \ 'rm': 'More',
  \ 'r?': 'Confirm',
  \ '!': 'Shell',
  \ 't': 'Terminal'
  \ }

let g:endoflines = {
  \ 'unix': 'lf',
  \ 'windows': 'crlf'
  \ }

function StatusLineNormal() abort
  let b:leftstatus = ''
  let b:rightstatus = ''
  
  let b:branch = FugitiveHead()

  hi SshGroup guibg=#fafafa guifg=#0d0d0d

  let b:leftstatus .= "%#SshGroup#    %#StatusLine#"

  let b:leftstatus .= '   '

  if !empty(b:branch)
    let b:leftstatus .= ' %{b:branch}   '
  endif

  let b:leftstatus .= ' %{StatusErrors()} '
  let b:leftstatus .= ' %{StatusWarnings()}   '

  let b:leftstatus .= '-- %{toupper(g:currentmode[mode()])} --'

  let b:rightstatus .= 'Spaces: %{&shiftwidth}'
  let b:rightstatus .= '   %{empty(&fenc)?toupper(&fenc):toupper(&enc)}'
  let b:rightstatus .= '   %{toupper(g:endoflines[&ff])}'

  if !empty(&ft) && &ft != 'TelescopePrompt'
    let b:rightstatus .= '    %{&ft}'
  endif

  let b:rightstatus .= '   '

  return b:leftstatus . '%=' . b:rightstatus
endfunction

function StatusWarnings() abort
  let info = get(b:, 'coc_diagnostic_info', {})

  if empty(info) | return '0' | endif

  return info['warning']
endfunction

function StatusErrors() abort
  let info = get(b:, 'coc_diagnostic_info', {})

  if empty(info) | return '0' | endif

  return info['error']
endfunction

set statusline=%!StatusLineNormal()

nmap <silent> <c-k> :wincmd k<CR>
nmap <silent> <c-j> :wincmd j<CR>
nmap <silent> <c-h> :wincmd h<CR>
nmap <silent> <c-l> :wincmd l<CR>
