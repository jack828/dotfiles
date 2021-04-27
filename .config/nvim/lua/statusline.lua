local lualine = require('lualine')

lualine.setup({
  options = {
    theme = 'material',
    section_separators = { '', '' },
    component_separators = { '', '' },
    icons_enabled = true
  },
  extensions = { 'fugitive', 'fzf', 'nerdtree' }
})
