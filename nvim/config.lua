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
}

