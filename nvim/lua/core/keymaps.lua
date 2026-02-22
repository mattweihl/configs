local map = vim.keymap.set

map("i", "jk", "<ESC>", { desc = "Exit insert mode" })

map("n", "<CR>", ":noh<CR><CR>", { desc = "Clear search highlight", silent = true })

map("n", "<leader>q", ":q!<CR>", { desc = "Quit", silent = true })
map("n", "<leader>qq", ":qa!<CR>", { desc = "Quit all", silent = true })
map("n", "<leader>wq", ":wqa!<CR>", { desc = "Save and quit all", silent = true })
map("n", "<leader>ww", ":w!<CR>", { desc = "Save", silent = true })

map("n", "<C-j>", "<C-w>j", { desc = "Move to below window" })
map("n", "<C-k>", "<C-w>k", { desc = "Move to above window" })
map("n", "<C-l>", "<C-w>l", { desc = "Move to right window" })

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

map("n", "]g", function() vim.diagnostic.jump({ count = 1 }) end, { desc = "Next diagnostic" })

map("n", "<C-a>", "ggVG", { desc = "Select all" })

