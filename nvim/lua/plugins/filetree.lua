return {
  {
    "nvim-neo-tree/neo-tree.nvim",
    branch = "v3.x",
    dependencies = {
      "nvim-lua/plenary.nvim",
      "nvim-tree/nvim-web-devicons",
      "MunifTanjim/nui.nvim",
    },
    keys = {
      { "<C-n>", "<cmd>Neotree toggle<cr>", desc = "Toggle file tree" },
    },
    opts = {
      close_if_last_window = true,
      popup_border_style = "rounded",
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "none",
          ["<2-LeftMouse>"] = "open",
          ["<RightMouse>"] = "show_file_details",
          ["a"] = {
            "add",
            config = {
              show_path = "relative",
            },
          },
          ["d"] = "delete",
          ["r"] = "rename",
          ["c"] = "copy",
          ["m"] = "move",
          ["y"] = "copy_to_clipboard",
          ["x"] = "cut_to_clipboard",
          ["p"] = "paste_from_clipboard",
          ["?"] = "show_help",
        },
      },
      commands = {
        show_file_details = function(state)
          local node = state.tree:get_node()
          if node then
            vim.cmd("Neotree action=focus")
            require("neo-tree.sources.filesystem.commands").show_file_details(state)
          end
        end,
      },
      event_handlers = {
        {
          event = "file_opened",
          handler = function()
            vim.cmd("Neotree close")
          end,
        },
      },
      filesystem = {
        filtered_items = {
          visible = true,
          hide_dotfiles = false,
          hide_gitignored = false,
        },
        follow_current_file = {
          enabled = true,
        },
        use_libuv_file_watcher = true,
      },
      default_component_configs = {
        indent = {
          with_expanders = true,
        },
        git_status = {
          symbols = {
            added = "+",
            modified = "~",
            deleted = "✖",
            renamed = "➜",
            untracked = "?",
            ignored = "◌",
            staged = "✓",
            conflict = "",
          },
        },
      },
    },
  },
}
