local opt = vim.opt

vim.g.mapleader = " "
vim.g.maplocalleader = " "

opt.number = true
opt.relativenumber = false

opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmode = false
opt.shortmess:append("FI")
opt.list = true
opt.listchars = { tab = "␉·" }
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 10

opt.backspace = "indent,eol,start"
opt.hidden = true
opt.mouse = "a"
opt.encoding = "utf-8"
opt.fileencoding = "utf-8"
opt.updatetime = 250
opt.timeoutlen = 300
opt.wildmenu = true
opt.wildmode = "list:longest"
opt.wildignore:append("*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx")
opt.splitbelow = true
opt.splitright = true
opt.wrap = false
opt.linebreak = true

opt.backup = false
opt.writebackup = false
opt.swapfile = false

opt.undofile = true

opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

opt.autoindent = true
opt.smartindent = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.expandtab = true
opt.smarttab = true

opt.clipboard = "unnamedplus"

opt.history = 1000

