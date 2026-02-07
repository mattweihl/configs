--------------------------------------------------------------------------------
-- Key Mappings
--------------------------------------------------------------------------------

local map = vim.keymap.set

-- Escape insert mode
map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

-- Clear search highlight with Enter
map("n", "<CR>", ":noh<CR><CR>", { desc = "Clear search highlight", silent = true })

-- File operations
map("n", "<leader>q", ":q!<CR>", { desc = "Quit", silent = true })
map("n", "<leader>qq", ":qa!<CR>", { desc = "Quit all", silent = true })
map("n", "<leader>wq", ":wqa!<CR>", { desc = "Save and quit all", silent = true })
map("n", "<leader>ww", ":w!<CR>", { desc = "Save", silent = true })

-- Better window navigation
map("n", "<C-h>", "<C-w>h", { desc = "Move to left window" })
map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

-- Resize windows
map("n", "<C-Up>", ":resize +2<CR>", { desc = "Increase window height", silent = true })
map("n", "<C-Down>", ":resize -2<CR>", { desc = "Decrease window height", silent = true })
map("n", "<C-Left>", ":vertical resize -2<CR>", { desc = "Decrease window width", silent = true })
map("n", "<C-Right>", ":vertical resize +2<CR>", { desc = "Increase window width", silent = true })

-- Move lines up/down (VS Code Alt+Up/Down)
map("n", "<A-j>", ":m .+1<CR>==", { desc = "Move line down", silent = true })
map("n", "<A-k>", ":m .-2<CR>==", { desc = "Move line up", silent = true })
map("v", "<A-j>", ":m '>+1<CR>gv=gv", { desc = "Move selection down", silent = true })
map("v", "<A-k>", ":m '<-2<CR>gv=gv", { desc = "Move selection up", silent = true })

-- Better indenting (stay in visual mode)
map("v", "<", "<gv", { desc = "Indent left" })
map("v", ">", ">gv", { desc = "Indent right" })

-- Buffer navigation (barbar)
map("n", "<S-h>", "<cmd>BufferPrevious<CR>", { desc = "Previous buffer" })
map("n", "<S-l>", "<cmd>BufferNext<CR>", { desc = "Next buffer" })
map("n", "<leader>bc", "<cmd>BufferClose<CR>", { desc = "Close buffer" })
map("n", "<leader>bp", "<cmd>BufferPin<CR>", { desc = "Pin buffer" })

-- Select all
map("n", "<C-a>", "ggVG", { desc = "Select all" })

-- Diagnostic navigation (same as old CoC bindings)
map("n", "[g", vim.diagnostic.goto_prev, { desc = "Previous diagnostic" })
map("n", "]g", vim.diagnostic.goto_next, { desc = "Next diagnostic" })
