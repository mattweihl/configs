""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Neovim Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""

" General Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
filetype plugin indent on
syntax on
runtime macros/matchit.vim

" Leader Key
let mapleader=" "

" Plugins (vim-plug)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
call plug#begin()
" Core functionality
Plug 'ojroques/vim-oscyank', {'branch': 'main'}
Plug 'scrooloose/nerdtree'
Plug 'jiangmiao/auto-pairs' 
Plug 'neoclide/coc.nvim', {'do': { -> coc#util#install()}}
Plug 'lewis6991/gitsigns.nvim'
Plug 'romgrk/barbar.nvim'
Plug 'sheerun/vim-polyglot'
Plug 'folke/trouble.nvim'

" Telescope and dependencies
Plug 'nvim-lua/plenary.nvim'
Plug 'nvim-telescope/telescope.nvim'
Plug 'LinArcX/telescope-command-palette.nvim'

" UI enhancements
Plug 'nvim-lualine/lualine.nvim'
" Plug 'lukas-reineke/indent-blankline.nvim'

" Icons
Plug 'ryanoasis/vim-devicons'
Plug 'nvim-tree/nvim-web-devicons'

" Colorschemes 
Plug 'sonph/onehalf', { 'rtp': 'vim' }
Plug 'folke/tokyonight.nvim'
Plug 'ellisonleao/gruvbox.nvim'
Plug 'navarasu/onedark.nvim'
Plug 'sainnhe/everforest'
Plug 'cocopon/iceberg.vim'
Plug 'folke/tokyonight.nvim'

" Theme switcher
Plug 'zaldih/themery.nvim'

" AI assistants
"Plug 'github/copilot.vim'
Plug 'xTacobaco/cursor-agent.nvim'
call plug#end()

" Appearance
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set background=light
colorscheme gruvbox 
set number
set cursorline
set list
set listchars=tab:␉·
set shortmess=FI

" Editor Behavior
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set backspace=indent,eol,start
set hidden                    
set ruler                     
set wildmenu                  
set mouse=a
set clipboard^=unnamed,unnamedplus
set nobackup
set nowritebackup
set history=1000
set wildmode=list:longest
set wildignore=*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx
set encoding=utf-8
set fileencoding=utf-8
set updatetime=300

" Search Settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set hlsearch
set incsearch
set ignorecase
set smartcase

" Indentation
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
set autoindent
set shiftwidth=2
set softtabstop=2
set expandtab
set smarttab

" Key Mappings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Escape insert mode
inoremap jk <ESC>

" NERDTree toggle
nmap <C-n> :NERDTreeToggle<CR>

" Clear search highlight with Enter
nnoremap <CR> :noh<CR><CR>

" File operations
nmap <silent> <leader>q :q!<CR>
nmap <silent> <leader>qq :qa!<CR>
nmap <silent> <leader>wq :wqa!<CR>
nmap <silent> <leader>ww :w!<CR>

" Reload configuration
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

" Telescope
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>ff <cmd>Telescope find_files<cr>
nnoremap <leader>fg <cmd>Telescope live_grep<cr>
nnoremap <leader>fb <cmd>Telescope buffers<cr>
nnoremap <leader>fh <cmd>Telescope help_tags<cr>

" Cursor Agent
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
nnoremap <leader>ca <cmd>CursorAgentToggle<cr>

" OSC Yank (for terminal copy)
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
autocmd TextYankPost * if v:event.operator == 'y' && v:event.regname == ''
                        \ | if exists(':OSCYankRegister') == 2
                        \ |     execute 'OSCYankRegister"'
                        \ | elseif exists(':OSCYankReg') == 2
                        \ |     execute 'OSCYankReg"'
                        \ | endif
                        \ | endif

" CoC Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
" Tab completion
inoremap <silent><expr> <TAB>
      \ coc#pum#visible() ? coc#pum#next(1) :
      \ CheckBackspace() ? "\<Tab>" :
      \ coc#refresh()
inoremap <expr><S-TAB> coc#pum#visible() ? coc#pum#prev(1) : "\<C-h>"

" Make <CR> to accept selected completion item
inoremap <silent><expr> <CR> coc#pum#visible() ? coc#pum#confirm()
                              \: "\<C-g>u\<CR>\<c-r>=coc#on_enter()\<CR>"

function! CheckBackspace() abort
  let col = col('.') - 1
  return !col || getline('.')[col - 1]  =~# '\s'
endfunction

" Use <c-space> to trigger completion
if has('nvim')
  inoremap <silent><expr> <c-space> coc#refresh()
else
  inoremap <silent><expr> <c-@> coc#refresh()
endif

" Navigation
nmap <silent> [g <Plug>(coc-diagnostic-prev)
nmap <silent> ]g <Plug>(coc-diagnostic-next)
nmap <silent> gd <Plug>(coc-definition)
nmap <silent> gy <Plug>(coc-type-definition)
nmap <silent> gi <Plug>(coc-implementation)
nmap <silent> gr <Plug>(coc-references)

" Documentation
nnoremap <silent> K :call ShowDocumentation()<CR>

function! ShowDocumentation()
  if CocAction('hasProvider', 'hover')
    call CocActionAsync('doHover')
  else
    call feedkeys('K', 'in')
  endif
endfunction

" Highlight symbols
autocmd CursorHold * silent call CocActionAsync('highlight')

" Symbol renaming and formatting
nmap <leader>rn <Plug>(coc-rename)
xmap <leader>f  <Plug>(coc-format-selected)
nmap <leader>f  <Plug>(coc-format-selected)

augroup mygroup
  autocmd!
  autocmd FileType typescript,json setl formatexpr=CocAction('formatSelected')
  autocmd User CocJumpPlaceholder call CocActionAsync('showSignatureHelp')
augroup end

" Code actions
xmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>a  <Plug>(coc-codeaction-selected)
nmap <leader>ac  <Plug>(coc-codeaction-cursor)
nmap <leader>as  <Plug>(coc-codeaction-source)
nmap <leader>qf  <Plug>(coc-fix-current)
nmap <silent> <leader>re <Plug>(coc-codeaction-refactor)
xmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <silent> <leader>r  <Plug>(coc-codeaction-refactor-selected)
nmap <leader>cl  <Plug>(coc-codelens-action)

" Text objects for functions/classes
xmap if <Plug>(coc-funcobj-i)
omap if <Plug>(coc-funcobj-i)
xmap af <Plug>(coc-funcobj-a)
omap af <Plug>(coc-funcobj-a)
xmap ic <Plug>(coc-classobj-i)
omap ic <Plug>(coc-classobj-i)
xmap ac <Plug>(coc-classobj-a)
omap ac <Plug>(coc-classobj-a)

" Scroll float windows
if has('nvim-0.4.0') || has('patch-8.2.0750')
  nnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  nnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
  inoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(1)\<cr>" : "\<Right>"
  inoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? "\<c-r>=coc#float#scroll(0)\<cr>" : "\<Left>"
  vnoremap <silent><nowait><expr> <C-f> coc#float#has_scroll() ? coc#float#scroll(1) : "\<C-f>"
  vnoremap <silent><nowait><expr> <C-b> coc#float#has_scroll() ? coc#float#scroll(0) : "\<C-b>"
endif

" Selections
nmap <silent> <C-s> <Plug>(coc-range-select)
xmap <silent> <C-s> <Plug>(coc-range-select)

" CoC commands
command! -nargs=0 Format :call CocActionAsync('format')
command! -nargs=? Fold :call CocAction('fold', <f-args>)
command! -nargs=0 OR   :call CocActionAsync('runCommand', 'editor.action.organizeImport')

" Status line integration
set statusline^=%{coc#status()}%{get(b:,'coc_current_function','')}

" CoC List mappings
nnoremap <silent><nowait> <space>a  :<C-u>CocList diagnostics<cr>
nnoremap <silent><nowait> <space>e  :<C-u>CocList extensions<cr>
nnoremap <silent><nowait> <space>c  :<C-u>CocList commands<cr>
nnoremap <silent><nowait> <space>o  :<C-u>CocList outline<cr>
nnoremap <silent><nowait> <space>s  :<C-u>CocList -I symbols<cr>
nnoremap <silent><nowait> <space>j  :<C-u>CocNext<CR>
nnoremap <silent><nowait> <space>k  :<C-u>CocPrev<CR>
nnoremap <silent><nowait> <space>p  :<C-u>CocListResume<CR>

" NERDTree settings
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
let NERDTreeShowHidden=1

" Lua Configuration
""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""""
lua require'config'

