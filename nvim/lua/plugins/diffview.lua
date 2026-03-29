return {
  "sindrets/diffview.nvim",
  cmd = { "DiffviewOpen", "DiffviewClose", "DiffviewFileHistory" },
  keys = {
    { "<leader>gd", "<cmd>DiffviewOpen<CR>", desc = "Git diff (working tree)" },
    { "<leader>gh", "<cmd>DiffviewFileHistory %<CR>", desc = "Git file history" },
    { "<leader>gq", "<cmd>DiffviewClose<CR>", desc = "Close diffview" },
  },
  opts = {
    enhanced_diff_hl = true,
    view = {
      default = { layout = "diff2_horizontal" },
    },
    file_panel = {
      listing_style = "tree",
      win_config = { width = 35 },
    },
  },
}
