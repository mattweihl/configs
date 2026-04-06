return {
  "3rd/image.nvim",
  build = false,
  event = "VeryLazy",
  opts = {
    backend = "kitty",
    processor = "magick_cli",
    tmux_show_only_in_active_window = true,
    integrations = {
      markdown = { enabled = true },
    },
    hijack_file_patterns = { "*.png", "*.jpg", "*.jpeg", "*.gif", "*.webp", "*.avif" },
  },
}
