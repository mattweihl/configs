return {
  {
    "saghen/blink.cmp",
    version = "1.*",
    event = "InsertEnter",
    dependencies = {
      "rafamadriz/friendly-snippets",
    },
    opts = {
      keymap = {
        ["<C-space>"] = { "show", "show_documentation", "hide_documentation" },
        ["<C-e>"] = { "hide" },
        ["<C-y>"] = { "select_and_accept" },
        ["<Tab>"] = { "select_and_accept", "snippet_forward", "fallback" },
        ["<S-Tab>"] = { "select_prev", "snippet_backward", "fallback" },
        ["<C-p>"] = { "select_prev", "fallback_to_mappings" },
        ["<C-n>"] = { "select_next", "fallback_to_mappings" },
        ["<C-b>"] = { "scroll_documentation_up", "fallback" },
        ["<C-f>"] = { "scroll_documentation_down", "fallback" },
      },
      completion = {
        -- Show docs alongside completion menu
        documentation = {
          auto_show = true,
          auto_show_delay_ms = 200,
        },
        -- Ghost text preview of the selected item
        ghost_text = { enabled = true },
      },
      -- Where completions come from
      sources = {
        default = { "lsp", "path", "snippets", "buffer" },
      },
      -- Fuzzy matching tuning
      fuzzy = {
        implementation = "rust",
      },
    },
  },
}
