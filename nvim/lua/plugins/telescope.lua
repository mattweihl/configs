return {
  {
    "nvim-telescope/telescope.nvim",
    branch = "master",
    cmd = "Telescope",
    dependencies = {
      "nvim-lua/plenary.nvim",
      { "nvim-telescope/telescope-fzf-native.nvim", build = "make" },
      "nvim-telescope/telescope-ui-select.nvim",
      "LinArcX/telescope-command-palette.nvim",
    },
    keys = {
      -- File finding (VS Code: Ctrl+P)
      { "<C-p>", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>ff", "<cmd>Telescope find_files<cr>", desc = "Find files" },
      { "<leader>fg", "<cmd>Telescope live_grep<cr>", desc = "Live grep" },
      { "<leader>fb", "<cmd>Telescope buffers<cr>", desc = "Buffers" },
      { "<leader>fh", "<cmd>Telescope help_tags<cr>", desc = "Help tags" },
      { "<leader>fs", "<cmd>Telescope grep_string<cr>", desc = "Grep word under cursor" },
      { "<leader>fd", "<cmd>Telescope diagnostics<cr>", desc = "Diagnostics" },
      { "<leader>fr", "<cmd>Telescope oldfiles<cr>", desc = "Recent files" },
      { "<leader>fc", "<cmd>Telescope command_palette<cr>", desc = "Command palette" },
      { "<leader>fk", "<cmd>Telescope keymaps<cr>", desc = "Keymaps" },
      { "<leader>ft", "<cmd>Telescope colorscheme<cr>", desc = "Colorschemes" },
      { "<leader>fo", "<cmd>Telescope lsp_document_symbols<cr>", desc = "Document symbols" },
      { "<leader>fw", "<cmd>Telescope lsp_workspace_symbols<cr>", desc = "Workspace symbols" },
    },
    config = function()
      local telescope = require("telescope")
      local actions = require("telescope.actions")

      telescope.setup({
        defaults = {
          vimgrep_arguments = {
            "rg", "--color=never", "--no-heading", "--with-filename",
            "--line-number", "--column", "--smart-case", "--hidden",
            "--glob=!.git/*",
          },
          file_ignore_patterns = {
            "node_modules/", "node%-offline%-mirror/", "node%-packages/",
            ".git/", "__pycache__/", "%.pyc", "dist/", "build/",
          },
          mappings = {
            i = {
              ["<C-j>"] = actions.move_selection_next,
              ["<C-k>"] = actions.move_selection_previous,
              ["<C-q>"] = actions.send_selected_to_qflist + actions.open_qflist,
              ["<esc>"] = actions.close,
            },
          },
          sorting_strategy = "ascending",
          layout_config = {
            horizontal = { prompt_position = "top", preview_width = 0.55 },
          },
          path_display = { "truncate" },
        },
        pickers = {
          find_files = {
            find_command = {
              "rg", "--files", "--hidden", "--no-ignore",
              "--glob=!node_modules/*",
              "--glob=!node-offline-mirror/*",
              "--glob=!node-packages/*",
              "--glob=!.git/*",
            },
          },
        },
        extensions = {
          fzf = {
            fuzzy = true,
            override_generic_sorter = true,
            override_file_sorter = true,
            case_mode = "smart_case",
          },
          ["ui-select"] = {
            require("telescope.themes").get_dropdown(),
          },
          command_palette = {
            { "File",
              { "entire selection (C-a)", ':call feedkeys("GVgg")' },
              { "save current file (C-s)", ":w" },
              { "save all files (C-A-s)", ":wa" },
              { "quit (C-q)", ":qa" },
              { "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
              { "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
              { "files (C-f)", ":lua require('telescope.builtin').find_files()", 1 },
            },
            { "Help",
              { "tips", ":help tips" },
              { "cheatsheet", ":help index" },
              { "tutorial", ":help tutor" },
              { "quick reference", ":help quickref" },
              { "search help (F1)", ":lua require('telescope.builtin').help_tags()", 1 },
            },
            { "Vim",
              { "reload config", ":source $MYVIMRC" },
              { "check health", ":checkhealth" },
              { "commands", ":lua require('telescope.builtin').commands()" },
              { "registers", ":lua require('telescope.builtin').registers()" },
              { "colorscheme", ":lua require('telescope.builtin').colorscheme()", 1 },
              { "keymaps", ":lua require('telescope.builtin').keymaps()" },
              { "buffers", ":Telescope buffers" },
            },
          },
        },
      })

      -- Load extensions
      telescope.load_extension("fzf")
      telescope.load_extension("ui-select")
      telescope.load_extension("command_palette")
    end,
  },
}
