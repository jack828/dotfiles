local nvim_lsp = require("lspconfig")
local lspfuzzy = require("lspfuzzy")
local lspinstall = require("lspinstall")

-- Make the LSP client use FZF instead of the quickfix list
lspfuzzy.setup {}

local on_attach = function(client, bufnr)
  local function buf_set_keymap(...) vim.api.nvim_buf_set_keymap(bufnr, ...) end
  local function buf_set_option(...) vim.api.nvim_buf_set_option(bufnr, ...) end

  buf_set_option('omnifunc', 'v:lua.vim.lsp.omnifunc')

  -- Mappings
  local opts = { noremap = true, silent = true }
  buf_set_keymap('n', 'gD', '<cmd>lua vim.lsp.buf.declaration()<CR>', opts)
  buf_set_keymap('n', 'gd', '<cmd>lua vim.lsp.buf.definition()<CR>', opts)
  buf_set_keymap('n', 'gi', '<cmd>lua vim.lsp.buf.implementation()<CR>', opts)
  buf_set_keymap('n', 'gr', '<cmd>lua vim.lsp.buf.references()<CR>', opts)
  buf_set_keymap('n', 'K', '<cmd>lua vim.lsp.buf.hover()<CR>', opts)
  buf_set_keymap('n', '<C-k>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
  buf_set_keymap('n', '<space>wa', '<cmd>lua vim.lsp.buf.add_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wr', '<cmd>lua vim.lsp.buf.remove_workspace_folder()<CR>', opts)
  buf_set_keymap('n', '<space>wl', '<cmd>lua print(vim.inspect(vim.lsp.buf.list_workspace_folders()))<CR>', opts)
  buf_set_keymap('n', '<space>D', '<cmd>lua vim.lsp.buf.type_definition()<CR>', opts)
  buf_set_keymap('n', '<space>rn', '<cmd>lua vim.lsp.buf.rename()<CR>', opts)
  buf_set_keymap('n', '<space>e', '<cmd>lua vim.lsp.diagnostic.show_line_diagnostics()<CR>', opts)
  buf_set_keymap('n', '[d', '<cmd>lua vim.lsp.diagnostic.goto_prev()<CR>', opts)
  buf_set_keymap('n', ']d', '<cmd>lua vim.lsp.diagnostic.goto_next()<CR>', opts)
  -- buf_set_keymap('n', '<space>q', '<cmd>lua vim.lsp.diagnostic.set_loclist()<CR>', opts)

  -- Linting
  if client.resolved_capabilities.document_formatting then
    buf_set_keymap("n", "<space>p", "<cmd>lua vim.lsp.buf.formatting_sync({}, 1000)<CR><cmd>w<CR>", opts)
    buf_set_keymap("n", "<space>P", "<cmd>lua vim.lsp.buf.formatting()<CR>", opts)
    -- vim.cmd [[autocmd BufWritePre *.jsx,*.jsx lua vim.lsp.buf.formatting_sync(nil, 1500)]]
  end
  -- elseif client.resolved_capabilities.document_range_formatting then
    -- buf_set_keymap("n", "<space>p", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  -- end

  -- Set autocommands conditional on server_capabilities
  if client.resolved_capabilities.document_highlight then
    vim.api.nvim_exec([[
      hi LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceText cterm=bold ctermbg=red guibg=LightYellow
      hi LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

-- setup installed language servers
lspinstall.setup()
local servers = lspinstall.installed_servers()

for _, lsp in ipairs(servers) do
  if lsp == 'typescript' then
    nvim_lsp[lsp].setup {
    on_attach = function(client, bufnr)
      client.resolved_capabilities.document_formatting = false

      on_attach(client, bufnr)
    end
  }
  elseif lsp == 'efm' then
    local eslint = {
      lintCommand = './node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}',
      lintIgnoreExitCode = true,
      lintStdin = true,
      lintFormats = { '%f:%l:%c: %m' }
    }
    local prettier = {
      formatCommand = './node_modules/.bin/prettier --config-precedence prefer-file --stdin-filepath ${INPUT}',
      formatStdin = true
    }
    local prettierHtml = {
      formatCommand = './node_modules/.bin/prettier --write ${--tab-width:tabWidth} ${--single-quote:singleQuote} --parser html --stdin-filepath ${INPUT}',
      formatStdin = true
    }
    local prettierCss = {
      formatCommand = './node_modules/.bin/prettier --write ${--tab-width:tabWidth} ${--single-quote:singleQuote} --parser css --stdin-filepath ${INPUT}',
      formatStdin = true
    }
    local prettierJson = {
      formatCommand = './node_modules/.bin/prettier --write ${--tab-width:tabWidth} ${--single-quote:singleQuote} --parser json --stdin-filepath ${INPUT}',
      formatStdin = true
    }
    local pugLint = {
      lintCommand = './node_modules/.bin/pug-lint --reporter inline',
      lintIgnoreExitCode = true,
      lintFormats = { '%f:%l:%c %m' },
      rootMarkers = { '.pug-lintrc', '.pug-lintrc.js', '.pug-lintrc.json' }
    }
    local jsonLint = {
      lintCommand = 'jq .',
      lintStdin = true,
      lintIgnoreExitCode = true,
    }


    nvim_lsp[lsp].setup {
      cmd = {
        '/home/jack/.local/share/nvim/lspinstall/efm/efm-langserver'
        , '-logfile', '/tmp/efm-lua.log', '-loglevel', '5'
      },
      on_attach = on_attach,
      init_options = {
        documentFormatting = true
      },
      settings = {
        rootMarkers = { '.git/' },
        lintDebounce = 1000000000, -- 1s in nanoseconds
        languages = {
          javascript = { eslint, prettier },
          javascriptreact = { eslint, prettier },
          typescript = { eslint, prettier },
          typescriptreact = { eslint, prettier },
          pug = { pugLint },
          jade = { pugLint },
          json = { jsonLint, prettierJson },
          html = { prettierHtml },
          css = { prettierCss },

        }
      },
      filetypes = {
        'javascriptreact',
        'javascript',
        'typescriptreact',
        'typescript',
        'pug',
        'jade',
        'json',
        'css',
        'html'
      }
    }
  else
    nvim_lsp[lsp].setup { on_attach = on_attach }
  end
end
