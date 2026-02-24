local treesitter = require('nvim-treesitter')

treesitter.setup()
treesitter.install {
  "bash",
  "c",
  "css",
  "graphql",
  "html",
  "javascript",
  "json",
  "lua",
  "tsx",
  "typescript",
  "yaml"
}
