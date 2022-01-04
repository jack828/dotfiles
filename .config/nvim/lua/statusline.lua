local lualine = require('lualine')

lualine.setup({
  options = {
    theme = 'material-nvim',
    section_separators = { '', '' },
    component_separators = { '', '' },
    icons_enabled = true
  },
  extensions = { 'fugitive', 'fzf', 'nerdtree' }
})
