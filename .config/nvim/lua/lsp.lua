local cmp_nvim_lsp = require("cmp_nvim_lsp")
local lspfuzzy = require("lspfuzzy")
local lspconfig = require("lspconfig")
local mason = require("mason")
local mason_lspconfig = require("mason-lspconfig")

-- Make the LSP client use FZF instead of the quickfix list
lspfuzzy.setup({})

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
  buf_set_keymap('n', '<C-s>', '<cmd>lua vim.lsp.buf.signature_help()<CR>', opts)
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
  if client.server_capabilities.documentFormattingProvider then
    buf_set_keymap("n", "<space>p", "<cmd>lua vim.lsp.buf.format()<CR><cmd>w<CR>", opts)
    -- vim.cmd [[autocmd BufWritePre *.jsx,*.jsx lua vim.lsp.buf.formatting_sync(nil, 1500)]]
  end
  -- elseif client.resolved_capabilities.document_range_formatting then
    -- buf_set_keymap("n", "<space>p", "<cmd>lua vim.lsp.buf.range_formatting()<CR>", opts)
  -- end

  -- Set autocommands conditional on server_capabilities
  if client.server_capabilities.documentHighlightProvider then
    vim.api.nvim_exec([[
      highlight LspReferenceRead cterm=bold ctermbg=red guibg=LightYellow guifg=black
      highlight LspReferenceText cterm=bold ctermbg=red guibg=LightYellow guifg=black
      highlight LspReferenceWrite cterm=bold ctermbg=red guibg=LightYellow guifg=black
      augroup lsp_document_highlight
        autocmd! * <buffer>
        autocmd CursorHold <buffer> lua vim.lsp.buf.document_highlight()
        autocmd CursorMoved <buffer> lua vim.lsp.buf.clear_references()
      augroup END
    ]], false)
  end
end

mason.setup({})

mason_lspconfig.setup({
  -- A list of servers to automatically install if they're not already installed
  ensure_installed = {
    "dockerls",
    "docker_compose_language_service",
    "efm",
    "ts_ls",
    "cssls",
    "clangd",
    "bashls",
    "html",
    "jsonls",
    "vimls",
    "yamlls",
    "arduino_language_server",
    "terraformls",
  },
})

local opts = {
  on_attach = on_attach,
  capabilities = cmp_nvim_lsp.default_capabilities(),
}

require("typescript-tools").setup({
  on_attach = function(client, bufnr)
    client.server_capabilities.documentFormattingProvider = false
    opts.on_attach(client, bufnr)
  end,
  capabilities = opts.capabilities,
  settings = {
    tsserver_max_memory = 1024, -- MB
    tsserver_file_preferences = function(ft)
      return {
        -- no idea if these are doing anything to make it """better"""
        includeInlayParameterNameHints = "all",
        includeCompletionsForModuleExports = true,
        includeInlayFunctionParameterTypeHints = true,
        includeInlayVariableTypeHints = true,
        includeInlayPropertyDeclarationTypeHints = true,
        includeInlayFunctionLikeReturnTypeHints = true,
        includeInlayEnumMemberValueHints = true,
      }
    end
  }
})

-- setup installed language servers
mason_lspconfig.setup_handlers({
  -- The first entry (without a key) will be the default handler
  -- and will be called for each installed server that doesn't have
  -- a dedicated handler.
  function(server_name) -- Default handler (optional)
    lspconfig[server_name].setup {
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
    }
  end,

  ["arduino_language_server"] = function()
    lspconfig["arduino_language_server"].setup({
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
      cmd = {
        "arduino-language-server",
        "-fqbn",
        "esp32:esp32:esp32",
        "-clangd", "/usr/bin/clangd",
        "-cli", "/home/jack/.local/bin/arduino-cli",
        "-cli-config", "/home/jack/.arduino15/arduino-cli.yaml"
      }
      -- i dont remember what this was trying to do ?
        -- on_new_config = function (config, root_dir)
            -- local partial_cmd = server:get_default_options().cmd
            -- local MY_FQBN = "esp32:esp32:esp32"
            -- config.cmd = vim.list_extend(partial_cmd, {
            -- "-fqbn", MY_FQBN,
            -- "-clangd", "/usr/bin/clangd-8"
            -- })
        -- end
    })
  end,

  ["clangd"] = function()
    lspconfig["clangd"].setup({
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
      filetypes = { "c", "cpp", "objc", "objcpp", "ino" },
    })
  end,

  ["ts_ls"] = function()
    -- managed by typescript-tools
  end,

  ["efm"] = function()
    local eslint = {
      lintCommand = './node_modules/.bin/eslint -f unix --stdin --stdin-filename ${INPUT}',
      lintIgnoreExitCode = true,
      lintStdin = true,
      lintFormats = { '%f:%l:%c: %m' }
    }
    -- TODO
    local stylint = {
      lintCommand = './node_modules/.bin/stylint ${INPUT}',
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
    local luacheck = {
      lintCommand = 'luacheck --globals vim --filename ${INPUT} --formatter plain -',
      lintStdin = true,
      lintFormats = { '%f:%l:%c: %m' }
    }
    local shellcheck = {
      lintCommand = 'shellcheck -f gcc -x',
      lintSource = 'shellcheck',
      lintFormats = {
        '%f:%l:%c: %trror: %m',
        '%f:%l:%c: %tarning: %m',
        '%f:%l:%c: %tote: %m',
      }
    }
    local shfmt = {
      formatCommand = 'shfmt -ci -s -bn -i 2',
      formatStdin = true
    }

    local languages = {
      javascript = { eslint, prettier },
      javascriptreact = { eslint, prettier },
      typescript = { eslint, prettier },
      typescriptreact = { eslint, prettier },
      pug = { pugLint },
      jade = { pugLint },
      json = { jsonLint, prettierJson },
      html = { prettierHtml },
      htmldjango = { prettier },
      css = { prettierCss },
      lua = { luacheck },
      sh = { shellcheck, shfmt },
      zsh = { shellcheck, shfmt }
    }

    lspconfig["efm"].setup({
      on_attach = opts.on_attach,
      capabilities = opts.capabilities,
      init_options = {
        documentFormatting = true
      },
      settings = {
        rootMarkers = { '.git/' },
        lintDebounce = 1000000000, -- 1s in nanoseconds
        languages = languages
      },
      filetypes = vim.tbl_keys(languages),
    })
  end,
})
