return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-tree/nvim-web-devicons", enabled = vim.g.have_nerd_font },
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>e", "<cmd>Neotree toggle<cr>", desc = "Toggle file explorer" },
      { "<leader>ge", "<cmd>Neotree git_status<cr>", desc = "Git explorer" },
    },
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          filtered_items = {
            visible = true,
            hide_dotfiles = false,
            hide_gitignored = false,
            never_show = { ".DS_Store", "thumbs.db" },
          },
          follow_current_file = { enabled = true },
          use_libuv_file_watcher = true,
        },
        window = {
          width = 35,
          mappings = {
            ["<space>"] = "none",
          },
        },
        default_component_configs = {
          icon = {
            folder_closed = vim.g.have_nerd_font and "" or ">",
            folder_open = vim.g.have_nerd_font and "" or "v",
            folder_empty = vim.g.have_nerd_font and "󰜌" or "-",
            default = vim.g.have_nerd_font and "*" or " ",
          },
          git_status = {
            symbols = vim.g.have_nerd_font and {
              added = "✚",
              modified = "",
              deleted = "✖",
              renamed = "󰁕",
              untracked = "",
              ignored = "",
              unstaged = "󰄱",
              staged = "",
              conflict = "",
            } or {
              added = "+",
              modified = "~",
              deleted = "x",
              renamed = ">",
              untracked = "?",
              ignored = ".",
              unstaged = "U",
              staged = "S",
              conflict = "!",
            },
          },
        },
      })
    end,
  },
}
