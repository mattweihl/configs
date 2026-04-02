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
      open_files_do_not_replace_types = { "terminal", "Trouble", "qf" },
      window = {
        position = "left",
        width = 30,
        mappings = {
          ["<space>"] = "none",
          ["<cr>"] = "open_drop",
          ["<2-LeftMouse>"] = "open_drop",
          ["s"] = "open_vsplit",
          ["S"] = "open_split",
          ["<RightMouse>"] = "noop",
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
      event_handlers = {
        {
          event = "file_added",
          handler = function(file_path)
            vim.cmd("edit " .. vim.fn.fnameescape(file_path))
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
