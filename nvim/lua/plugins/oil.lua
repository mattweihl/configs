return {
  "stevearc/oil.nvim",
  dependencies = { "nvim-tree/nvim-web-devicons" },
  keys = {
    { "-", "<cmd>Oil<cr>", desc = "Open parent directory" },
  },
  opts = {
    default_file_explorer = false,
    columns = { "icon" },
    view_options = {
      show_hidden = true,
    },
    skip_confirm_for_simple_edits = true,
    use_default_keymaps = true,
    keymaps = {
      ["q"] = "actions.close",
    },
  },
}
