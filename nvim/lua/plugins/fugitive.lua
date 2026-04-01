return {
  "tpope/vim-fugitive",
  cmd = "Git",
  keys = {
    { "<leader>gs", "<cmd>Git<cr>", desc = "Git status (fugitive)" },
    { "<leader>gb", "<cmd>Git blame<cr>", desc = "Git blame (full file)" },
    { "<leader>gl", "<cmd>Git log --oneline<cr>", desc = "Git log" },
  },
}
