local map = vim.keymap.set

map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

map("n", "<CR>", function()
  if vim.bo.buftype ~= "" then
    return vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
  end
  vim.cmd("noh")
end, { desc = "Clear search highlight", silent = true })

map("n", "<leader>q", function()
  if #vim.api.nvim_list_wins() > 1 then
    vim.cmd("close!")
  else
    -- Last window: switch to alternate buffer or create empty
    local bufs = vim.fn.getbufinfo({ buflisted = 1 })
    if #bufs > 1 then
      vim.cmd("bnext | bdelete! #")
    else
      vim.cmd("q!")
    end
  end
end, { desc = "Close split/buffer", silent = true })
map("n", "<leader>qq", ":qa!<CR>", { desc = "Quit all", silent = true })
map("n", "<leader>wq", ":wqa!<CR>", { desc = "Save and quit all", silent = true })
map("n", "<leader>ww", ":w!<CR>", { desc = "Save", silent = true })
map("n", "<leader>R", function()
  -- Re-source core config modules
  for _, mod in ipairs({ "core.options", "core.keymaps", "core.autocmds" }) do
    package.loaded[mod] = nil
    require(mod)
  end
  vim.notify("Config reloaded")
end, { desc = "Reload config" })

map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- Splits (VSCode-style editor groups)
map("n", "<leader>\\", "<cmd>vsplit<cr>", { desc = "Split right" })
map("n", "<leader>-", "<cmd>split<cr>", { desc = "Split down" })
map("n", "<leader>sx", "<cmd>close<cr>", { desc = "Close split" })
map("n", "<leader>so", "<cmd>only<cr>", { desc = "Close other splits" })

-- Navigate splits
map("n", "<leader>sh", "<cmd>wincmd h<cr>", { desc = "Move to left split" })
map("n", "<leader>sj", "<cmd>wincmd j<cr>", { desc = "Move to below split" })
map("n", "<leader>sk", "<cmd>wincmd k<cr>", { desc = "Move to above split" })
map("n", "<leader>sl", "<cmd>wincmd l<cr>", { desc = "Move to right split" })

-- Focus split by number (VSCode: Cmd+1/2/3/4)
map("n", "<leader>1", "1<C-w>w", { desc = "Focus split 1" })
map("n", "<leader>2", "2<C-w>w", { desc = "Focus split 2" })
map("n", "<leader>3", "3<C-w>w", { desc = "Focus split 3" })
map("n", "<leader>4", "4<C-w>w", { desc = "Focus split 4" })

-- Zoom toggle (VSCode: Toggle Editor Group Sizes)
map("n", "<leader>sm", function()
  if vim.t.zoomed then
    vim.cmd("wincmd =")
    vim.t.zoomed = false
  else
    vim.cmd("wincmd |")
    vim.cmd("wincmd _")
    vim.t.zoomed = true
  end
end, { desc = "Toggle zoom split" })

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

map("n", "]d", function() vim.diagnostic.jump({ count = 1, float = true }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1, float = true }) end, { desc = "Previous diagnostic" })

map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Yank with file path (useful for pasting into coding agents)
local function yank_with_path(use_absolute)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = use_absolute and bufname or vim.fn.fnamemodify(bufname, ":~:.")
    local mode = vim.fn.mode()
    local start_line, end_line

    if mode == "v" or mode == "V" or mode == "\22" then
      -- Visual mode: get selection
      vim.cmd('normal! "zy')
      local text = vim.fn.getreg("z")
      start_line = vim.fn.line("'<")
      end_line = vim.fn.line("'>")
      local header = path .. ":" .. start_line .. "-" .. end_line
      vim.fn.setreg("+", header .. "\n" .. text)
    else
      -- Normal mode: yank current line
      start_line = vim.fn.line(".")
      local text = vim.api.nvim_get_current_line()
      local header = path .. ":" .. start_line
      vim.fn.setreg("+", header .. "\n" .. text)
    end

    vim.notify("Yanked with " .. (use_absolute and "absolute" or "relative") .. " path")
  end
end

map({ "n", "v" }, "<leader>yr", yank_with_path(false), { desc = "Yank with relative path" })
map({ "n", "v" }, "<leader>ya", yank_with_path(true), { desc = "Yank with absolute path" })

local function yank_path_only(use_absolute)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = use_absolute and bufname or vim.fn.fnamemodify(bufname, ":~:.")
    vim.fn.setreg("+", path)
    vim.notify("Yanked " .. (use_absolute and "absolute" or "relative") .. " path")
  end
end

map("n", "<leader>yR", yank_path_only(false), { desc = "Yank relative path only" })
map("n", "<leader>yA", yank_path_only(true), { desc = "Yank absolute path only" })

-- Terminal toggle (<C-t>) — VSCode-style bottom terminal
-- Note: overrides vim's <C-t> (tag stack pop), which is unused with LSP navigation (<C-o> instead)
local term_buf = nil
local term_win = nil

local function toggle_terminal()
  if term_win and vim.api.nvim_win_is_valid(term_win) then
    vim.api.nvim_win_close(term_win, true)
    term_win = nil
    return
  end

  vim.cmd("botright 15split")
  if term_buf and vim.api.nvim_buf_is_valid(term_buf) then
    vim.api.nvim_win_set_buf(0, term_buf)
  else
    vim.cmd("terminal")
    term_buf = vim.api.nvim_get_current_buf()
    -- Scope Esc to this terminal only (so lazygit/fzf in other terminals work)
    map("t", "<Esc>", [[<C-\><C-n>]], { buffer = term_buf, desc = "Exit terminal mode" })
  end
  term_win = vim.api.nvim_get_current_win()
  vim.cmd("startinsert")
end

map({ "n", "t" }, "<C-t>", toggle_terminal, { desc = "Toggle terminal" })

-- Neovide GUI keymaps (Cmd key = <D-...>)
if vim.g.neovide then
  map("n", "<D-s>", "<cmd>w<CR>", { desc = "Save" })
  map("v", "<D-c>", '"+y', { desc = "Copy" })
  map("n", "<D-v>", '"+P', { desc = "Paste" })
  map("v", "<D-v>", '"+P', { desc = "Paste" })
  map("c", "<D-v>", "<C-R>+", { desc = "Paste" })
  map("i", "<D-v>", '<ESC>l"+Pli', { desc = "Paste" })
  map("t", "<D-v>", '<C-\\><C-n>"+Pi', { desc = "Paste in terminal" })

  -- Cmd+=/- to scale font (standard macOS zoom)
  vim.g.neovide_scale_factor = 1.0
  local function adjust_scale(delta)
    vim.g.neovide_scale_factor = vim.g.neovide_scale_factor * delta
  end
  map("n", "<D-=>", function() adjust_scale(1.1) end, { desc = "Zoom in" })
  map("n", "<D-->", function() adjust_scale(1 / 1.1) end, { desc = "Zoom out" })
  map("n", "<D-0>", function() vim.g.neovide_scale_factor = 1.0 end, { desc = "Reset zoom" })
end

-- Cmd+/ comment toggle (Ghostty sends \x1f = <C-_> for cmd+slash)
-- ts-comments.nvim hooks into Neovim 0.10 native gc/gcc and sets commentstring
-- via treesitter context, so JSX/TSX regions get {/* */} automatically
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("i", "<C-_>", "<C-o>gcc", { remap = true, desc = "Toggle comment (Cmd+/)" })

