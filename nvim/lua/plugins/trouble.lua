return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>xx",
      function() require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } }) end,
      desc = "Toggle diagnostics (this file)",
    },
    {
      "<leader>xw",
      function() require("trouble").toggle({ mode = "diagnostics" }) end,
      desc = "Toggle diagnostics (all files)",
    },
  },
  opts = {
    focus = true,
    auto_close = false,
    position = "bottom",
  },
}
