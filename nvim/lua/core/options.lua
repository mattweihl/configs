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
opt.fileencoding = "utf-8"
opt.updatetime = 250
opt.timeoutlen = 300
opt.wildmenu = true
opt.wildmode = "list:longest"
opt.wildignore:append("*.docx,*.jpg,*.png,*.gif,*.pdf,*.pyc,*.exe,*.flv,*.img,*.xlsx")
opt.splitbelow = true
opt.splitright = true
opt.wrap = true
opt.linebreak = true

opt.backup = false
opt.writebackup = false
opt.swapfile = false

-- Reload buffer when file changes on disk (e.g. Cursor Agent / Claude editing the file).
opt.autoread = true

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

-- GUI font (Neovide / nvim-qt); ignored by terminal Neovim
opt.guifont = "Iosevka_Nerd_Font_Mono,Menlo,monospace:h14"

if vim.g.neovide then
  -- macOS Option key sends Alt (needed for <A-j>/<A-k> line-move keymaps)
  vim.g.neovide_input_macos_option_key_is_meta = "both"

  -- Padding (pixels) — breathing room around the editor
  vim.g.neovide_padding_top = 4
  vim.g.neovide_padding_bottom = 4
  vim.g.neovide_padding_left = 8
  vim.g.neovide_padding_right = 8

  -- Animations — TODO: tune these to your taste (see below)
  vim.g.neovide_cursor_animation_length = 0.06
  vim.g.neovide_cursor_trail_size = 0.4
  vim.g.neovide_scroll_animation_length = 0.1
end

opt.history = 1000
opt.exrc = true

