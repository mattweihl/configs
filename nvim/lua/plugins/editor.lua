return {
  {
    "windwp/nvim-autopairs",
    event = "InsertEnter",
    config = function()
      local autopairs = require("nvim-autopairs")
      autopairs.setup({
        check_ts = true,
        ts_config = {
          lua = { "string" },
          javascript = { "template_string" },
          typescript = { "template_string" },
        },
      })

    end,
  },

  {
    "numToStr/Comment.nvim",
    keys = {
      { "gcc", mode = "n", desc = "Toggle comment" },
      { "gc", mode = { "n", "v" }, desc = "Comment" },
      { "gbc", mode = "n", desc = "Toggle block comment" },
      { "gb", mode = { "n", "v" }, desc = "Block comment" },
    },
    config = function()
      require("Comment").setup()
    end,
  },

  {
    "kylechui/nvim-surround",
    version = "*",
    keys = { "ys", "ds", "cs" },
    config = function()
      require("nvim-surround").setup()
    end,
  },
}

