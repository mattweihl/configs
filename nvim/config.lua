require('telescope').setup{ 
  defaults = { 
    file_ignore_patterns = { 
      "node_modules", 
      "node-offline-mirror",
      "node-packages",
      ".git"
    }
  }
}
