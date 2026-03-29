return {
  "folke/trouble.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    {
      "<leader>xx",
      function() require("trouble").toggle({ mode = "diagnostics", filter = { buf = 0 } }) end,
      desc = "Errors (this file)",
    },
    {
      "<leader>xw",
      function() require("trouble").toggle({ mode = "diagnostics" }) end,
      desc = "Errors (all files)",
    },
  },
  opts = {
    focus = true,
    auto_close = false,
    position = "bottom",
  },
}
