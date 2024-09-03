require('telescope').setup{
  defaults = {
    vimgrep_arguments = {
      'rg',
      '--color=never',
      '--no-heading',
      '--with-filename',
      '--line-number',
      '--column',
      '--smart-case'
    },
    file_ignore_patterns = {
      "node_modules/*",
      "node-offline-mirror/*",
      "node-packages/*",
    },
  },
  pickers = {
    find_files = {
      find_command = {
        'rg', '--files', '--hidden', '--no-ignore', '--glob=!node_modules/*', '--glob=!node-offline-mirror/*', '--glob=!node-packages/*'
      }
    },
  },
  extensions = {
    command_palette = {
      {"File",
        { "entire selection (C-a)", ':call feedkeys("GVgg")' },
        { "save current file (C-s)", ':w' },
        { "save all files (C-A-s)", ':wa' },
        { "quit (C-q)", ':qa' },
        { "file browser (C-i)", ":lua require'telescope'.extensions.file_browser.file_browser()", 1 },
        { "search word (A-w)", ":lua require('telescope.builtin').live_grep()", 1 },
        { "git files (A-f)", ":lua require('telescope.builtin').git_files()", 1 },
        { "files (C-f)",     ":lua require('telescope.builtin').find_files()", 1 },
      },
      {"Help",
        { "tips", ":help tips" },
        { "cheatsheet", ":help index" },
        { "tutorial", ":help tutor" },
        { "summary", ":help summary" },
        { "quick reference", ":help quickref" },
        { "search help(F1)", ":lua require('telescope.builtin').help_tags()", 1 },
      },
      {"Vim",
        { "reload vimrc", ":source $MYVIMRC" },
        { 'check health', ":checkhealth" },
        { "jumps (Alt-j)", ":lua require('telescope.builtin').jumplist()" },
        { "commands", ":lua require('telescope.builtin').commands()" },
        { "command history", ":lua require('telescope.builtin').command_history()" },
        { "registers (A-e)", ":lua require('telescope.builtin').registers()" },
        { "colorshceme", ":lua require('telescope.builtin').colorscheme()", 1 },
        { "vim options", ":lua require('telescope.builtin').vim_options()" },
        { "keymaps", ":lua require('telescope.builtin').keymaps()" },
        { "buffers", ":Telescope buffers" },
        { "search history (C-h)", ":lua require('telescope.builtin').search_history()" },
        { "paste mode", ':set paste!' },
        { 'cursor line', ':set cursorline!' },
        { 'cursor column', ':set cursorcolumn!' },
        { "spell checker", ':set spell!' },
        { "relative number", ':set relativenumber!' },
        { "search highlighting (F12)", ':set hlsearch!' },
      }
    }
  }
}

require('lualine').setup {
  options = {
    icons_enabled = true,
    theme = 'auto',
    component_separators = { left = '', right = ''},
    section_separators = { left = '', right = ''},
    disabled_filetypes = {
      statusline = {},
      winbar = {},
    },
    ignore_focus = {},
    always_divide_middle = true,
    globalstatus = false,
    refresh = {
      statusline = 1000,
      tabline = 1000,
      winbar = 1000,
    }
  },
  sections = {
    lualine_a = {'mode'},
    lualine_b = {'branch', 'diff', 'diagnostics'},
    lualine_c = {'filename'},
    lualine_x = {'encoding', 'fileformat', 'filetype'},
    lualine_y = {'progress'},
    lualine_z = {'location'}
  },
  inactive_sections = {
    lualine_a = {},
    lualine_b = {},
    lualine_c = {'filename'},
    lualine_x = {'location'},
    lualine_y = {},
    lualine_z = {}
  },
  tabline = {},
  winbar = {},
  inactive_winbar = {},
  extensions = {}
}
require('telescope').load_extension('command_palette')
require("ibl").setup()

