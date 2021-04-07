local treesitter = require('nvim-treesitter.configs')

treesitter.setup {
  -- one of "all", "maintained" (parsers with maintainers), or a list of languages
  ensure_installed = {
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
  },
  highlight = {
    -- false will disable the whole extension
    enabled = true,
    -- list of languages that will be disabled
    disable = {}
  },
  indent = {
    enable = true
  }
}
