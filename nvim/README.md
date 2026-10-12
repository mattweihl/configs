# Neovim configuration

`nvim/` links to `~/.config/nvim/`.

`init.lua` loads `core/` before `lazy.setup("plugins")` discovers `lua/plugins/*.lua`.

The default indentation is two spaces. Python uses four spaces through an autocmd.

Blink provides completion through `nvim/lua/plugins/completion.lua`.

Formatting and trailing-whitespace cleanup are manual through `<leader>F` or the context menu.

Saving does not invoke Conform.

Read `agents/reference/formatting.md` before changing formatter configuration.
