return {
  {
    "folke/edgy.nvim",
    event = "VeryLazy",
    opts = {
      -- Left panels
      left = {
        {
          title = "Files",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "filesystem"
          end,
          size = { width = 35 },
          pinned = true,
          open = "Neotree position=left filesystem",
        },
        {
          title = "Git Status",
          ft = "neo-tree",
          filter = function(buf)
            return vim.b[buf].neo_tree_source == "git_status"
          end,
          pinned = true,
          open = "Neotree position=left git_status",
        },
        -- DAP UI panels
        { title = "Scopes", ft = "dapui_scopes", size = { height = 0.35 } },
        { title = "Breakpoints", ft = "dapui_breakpoints", size = { height = 0.15 } },
        { title = "Stacks", ft = "dapui_stacks", size = { height = 0.25 } },
        { title = "Watches", ft = "dapui_watches", size = { height = 0.25 } },
      },
      -- Bottom panels
      bottom = {
        { ft = "trouble", title = "Diagnostics", size = { height = 10 } },
        { ft = "toggleterm", title = "Terminal", size = { height = 15 } },
        { ft = "dap-repl", title = "REPL" },
        { ft = "dapui_console", title = "Console" },
      },
      -- Right panels
      right = {
        { ft = "grug-far", title = "Search & Replace", size = { width = 60 } },
        { ft = "DiffviewFiles", title = "Diff View", size = { width = 35 } },
      },
    },
  },
}
