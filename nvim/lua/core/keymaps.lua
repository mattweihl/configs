local map = vim.keymap.set

map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

map("n", "<CR>", function()
  if vim.bo.buftype ~= "" then
    return vim.api.nvim_feedkeys(vim.keycode("<CR>"), "n", false)
  end
  vim.cmd("noh")
end, { desc = "Clear search highlight", silent = true })

map("n", "<leader>q", ":q!<CR>", { desc = "Quit", silent = true })
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

map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

map("n", "]d", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })
map("n", "[d", function() vim.diagnostic.jump({ count = -1 }) end, { desc = "Previous diagnostic" })

map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Yank with file path (useful for pasting into coding agents)
local function yank_with_path(use_absolute)
  return function()
    local bufname = vim.api.nvim_buf_get_name(0)
    local path = use_absolute and bufname or vim.fn.fnamemodify(bufname, ":~:.")
    local mode = vim.fn.mode()
    local start_line, end_line, lines

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

-- Cmd+/ comment toggle (Ghostty sends \x1f = <C-_> for cmd+slash)
-- ts-comments.nvim hooks into Neovim 0.10 native gc/gcc and sets commentstring
-- via treesitter context, so JSX/TSX regions get {/* */} automatically
map("n", "<C-_>", "gcc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("x", "<C-_>", "gc", { remap = true, desc = "Toggle comment (Cmd+/)" })
map("i", "<C-_>", "<C-o>gcc", { remap = true, desc = "Toggle comment (Cmd+/)" })

