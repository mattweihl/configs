return {
  {
    "Mofiqul/vscode.nvim",
    lazy = false,
    priority = 1000,
    config = function()
      require("vscode").setup({
        style = "dark",
        transparent = false,
      })
      require("vscode").load()
    end,
  },

  {
    "nvim-lualine/lualine.nvim",
    event = "VeryLazy",
    dependencies = {
      { "nvim-tree/nvim-web-devicons", enabled = true },
    },
    config = function()

      require("lualine").setup({
        options = {
          icons_enabled = nf,
          theme = "auto",
          component_separators = { left = "", right = "" },
          section_separators = { left = "", right = "" },
          globalstatus = true,
        },
        sections = {
          lualine_a = { "mode" },
          lualine_b = { "branch", "diff" },
          lualine_c = { { "filename", path = 1 } },
          lualine_x = { "encoding", "fileformat", "filetype" },
          lualine_y = { "progress" },
          lualine_z = { "location" },
        },
      })
    end,
  },

  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      {
        "<leader>?",
        function()
          require("which-key").show({ global = true })
        end,
        desc = "Show all keybindings",
      },
    },
    config = function()
      local wk = require("which-key")

      wk.setup({
        preset = "modern",
        delay = 300,
        icons = {
          breadcrumb = "»",
          separator = "➜",
          group = "+",
        },
        win = {
          border = "rounded",
        },
      })

      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>f", group = "Find/File" },
        { "<leader>w", group = "Write/Quit" },
      })
    end,
  },
}

