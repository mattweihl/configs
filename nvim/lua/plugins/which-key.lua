return {
  {
    "folke/which-key.nvim",
    event = "VeryLazy",
    keys = {
      -- Keybinding cheat sheet modal
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

      -- Register key groups for organized display
      wk.add({
        { "<leader>b", group = "Buffer" },
        { "<leader>c", group = "Code" },
        { "<leader>d", group = "Debug" },
        { "<leader>f", group = "Find/File" },
        { "<leader>g", group = "Git" },
        { "<leader>h", group = "Git hunks" },
        { "<leader>r", group = "Rename/Refactor" },
        { "<leader>s", group = "Search/Replace" },
        { "<leader>w", group = "Write/Quit" },
        { "<leader>x", group = "Diagnostics/Trouble" },
      })
    end,
  },
}
