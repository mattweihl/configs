--------------------------------------------------------------------------------
-- Editor Options
--------------------------------------------------------------------------------

local opt = vim.opt

-- Leader key
vim.g.mapleader = " "
vim.g.maplocalleader = " "

-- Set to true if your terminal has a Nerd Font installed
vim.g.have_nerd_font = false

-- Line numbers
opt.number = true
opt.relativenumber = false

-- Appearance
opt.cursorline = true
opt.termguicolors = true
opt.signcolumn = "yes"
opt.showmode = false -- lualine shows mode
opt.shortmess:append("FI")
opt.list = true
opt.listchars = { tab = "␉·" }
opt.scrolloff = 8
opt.sidescrolloff = 8
opt.pumheight = 10 -- completion menu height

-- Editor behavior
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

-- No backup files
opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Persistent undo
opt.undofile = true

-- Search
opt.hlsearch = true
opt.incsearch = true
opt.ignorecase = true
opt.smartcase = true

-- Indentation
opt.autoindent = true
opt.smartindent = true
opt.shiftwidth = 2
opt.softtabstop = 2
opt.tabstop = 2
opt.expandtab = true
opt.smarttab = true

-- Clipboard: use OSC 52 for SSH/tmux compatibility
-- Works across macOS, Linux, SSH sessions, and tmux
opt.clipboard = "unnamedplus"

-- History
opt.history = 1000
