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
    -- Load neo-tree early when nvim opens a directory (e.g. nvim .)
    -- so its built-in netrw hijack can intercept cleanly
    init = function()
      if vim.fn.argc(-1) > 0 then
        vim.api.nvim_create_autocmd("BufEnter", {
          group = vim.api.nvim_create_augroup("NeoTreeDirectoryHijack", { clear = true }),
          once = true,
          callback = function()
            if package.loaded["neo-tree"] then return end
            local stat = vim.uv.fs_stat(vim.fn.argv(0))
            if stat and stat.type == "directory" then
              require("neo-tree")
            end
          end,
        })
      end
    end,
    config = function()
      require("neo-tree").setup({
        close_if_last_window = true,
        popup_border_style = "rounded",
        enable_git_status = true,
        enable_diagnostics = true,
        filesystem = {
          hijack_netrw_behavior = "open_default",
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
        -- Only override defaults when Nerd Font is off (ASCII fallbacks).
        -- When Nerd Font is on, neo-tree's built-in icons work out of the box.
        default_component_configs = not vim.g.have_nerd_font and {
          icon = {
            folder_closed = ">",
            folder_open = "v",
            folder_empty = "-",
            default = " ",
          },
          git_status = {
            symbols = {
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
        } or {},
      })
    end,
  },
}
