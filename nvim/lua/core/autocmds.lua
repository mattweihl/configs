--------------------------------------------------------------------------------
-- Autocommands
--------------------------------------------------------------------------------

local augroup = vim.api.nvim_create_augroup
local autocmd = vim.api.nvim_create_autocmd

-- Highlight on yank
augroup("YankHighlight", { clear = true })
autocmd("TextYankPost", {
  group = "YankHighlight",
  callback = function()
    vim.hl.on_yank({ timeout = 200 })
  end,
})

-- Remove trailing whitespace on save
augroup("TrimWhitespace", { clear = true })
autocmd("BufWritePre", {
  group = "TrimWhitespace",
  pattern = "*",
  command = "%s/\\s\\+$//e",
})

-- Return to last edit position when opening files
augroup("RestoreCursor", { clear = true })
autocmd("BufReadPost", {
  group = "RestoreCursor",
  callback = function()
    local mark = vim.api.nvim_buf_get_mark(0, '"')
    local lcount = vim.api.nvim_buf_line_count(0)
    if mark[1] > 0 and mark[1] <= lcount then
      pcall(vim.api.nvim_win_set_cursor, 0, mark)
    end
  end,
})

-- Auto-resize splits when terminal is resized
augroup("ResizeSplits", { clear = true })
autocmd("VimResized", {
  group = "ResizeSplits",
  callback = function()
    vim.cmd("tabdo wincmd =")
  end,
})

-- Set filetype-specific indentation
augroup("FileTypeIndent", { clear = true })
autocmd("FileType", {
  group = "FileTypeIndent",
  pattern = { "python" },
  callback = function()
    vim.opt_local.shiftwidth = 4
    vim.opt_local.tabstop = 4
    vim.opt_local.softtabstop = 4
  end,
})

-- Large file guard — disable expensive features for files >1MB
augroup("LargeFile", { clear = true })
autocmd("BufReadPre", {
  group = "LargeFile",
  callback = function(args)
    local ok, stats = pcall(vim.uv.fs_stat, vim.api.nvim_buf_get_name(args.buf))
    if ok and stats and stats.size > 1024 * 1024 then
      vim.b[args.buf].large_file = true
      vim.opt_local.syntax = ""
      vim.opt_local.foldmethod = "manual"
      vim.opt_local.cursorline = false
      vim.opt_local.swapfile = false
      vim.opt_local.undofile = false
      -- Disable treesitter highlighting for this buffer
      vim.schedule(function()
        pcall(vim.treesitter.stop, args.buf)
      end)
      -- Detach LSP clients (they choke on huge files)
      vim.schedule(function()
        for _, client in pairs(vim.lsp.get_clients({ bufnr = args.buf })) do
          vim.lsp.buf_detach_client(args.buf, client.id)
        end
      end)
    end
  end,
})

-- Right-click context menu (extends Neovim 0.11 built-in PopUp menu)
local nf = vim.g.have_nerd_font

-- LSP actions
vim.cmd("amenu PopUp.-lsp_sep- <Nop>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Go\\ to\\ Definition       <cmd>lua vim.lsp.buf.definition()<CR>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Find\\ References          <cmd>lua vim.lsp.buf.references()<CR>")
vim.cmd("amenu PopUp." .. (nf and "󰏫\\ " or "") .. "Rename\\ Symbol            <cmd>lua vim.lsp.buf.rename()<CR>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Code\\ Action               <cmd>lua vim.lsp.buf.code_action()<CR>")

-- Tools
vim.cmd("amenu PopUp.-tools_sep- <Nop>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Format\\ File              <cmd>lua require('conform').format()<CR>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Line\\ Diagnostics        <cmd>lua vim.diagnostic.open_float()<CR>")
vim.cmd("amenu PopUp." .. (nf and "\\ " or "") .. "Toggle\\ Breakpoint       <cmd>lua require('dap').toggle_breakpoint()<CR>")

-- Search / Git
vim.cmd("amenu PopUp.-git_sep- <Nop>")
vim.cmd("amenu PopUp." .. (nf and "󰈞\\ " or "") .. "Search\\ Word             <cmd>lua require('telescope.builtin').grep_string()<CR>")
vim.cmd("amenu PopUp." .. (nf and "󰊢\\ " or "") .. "Git\\ Blame               <cmd>lua require('gitsigns').blame_line({ full = true })<CR>")

-- Auto-reload files changed externally (e.g. cursor-agent in another tmux pane)
augroup("AutoReload", { clear = true })
autocmd({ "FocusGained", "BufEnter", "CursorHold", "CursorHoldI" }, {
  group = "AutoReload",
  command = "checktime",
})
autocmd("FileChangedShellPost", {
  group = "AutoReload",
  callback = function()
    vim.notify("File changed on disk. Buffer reloaded.", vim.log.levels.INFO)
  end,
})
