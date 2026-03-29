return {
  {
    "folke/edgy.nvim",
    enabled = false, -- Enable if you want VSCode-style docked panel tabs
    event = "VeryLazy",
    opts = {
      bottom = {
        { ft = "trouble", title = "Problems" },
        { ft = "qf", title = "Quickfix" },
        { ft = "terminal", title = "Terminal" },
      },
      left = {
        { ft = "neo-tree", title = "Explorer", size = { width = 35 } },
      },
    },
  },
}
