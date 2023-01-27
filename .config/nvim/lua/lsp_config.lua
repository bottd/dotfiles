-- TODO: omnifunc integration for nvim-cmp to integrate LSP with completion
-- ** omnifunc from neovim lsp accessible here -> vim.lsp.omnifunc handler 
--
-- lsp-buf functions have a _sync variant for use when desired
-- Example:
-- Auto-format *.rs (rust) files prior to saving them
-- autocmd BufWritePre *.rs lua vim.lsp.buf.formatting_sync(nil, 1000)
require("mason").setup {
  ui = {
    icons = {
      package_installed = "✓",
      package_pending = "➜",
      package_uninstalled = "✗"
    }
  }
}


local servers = {
  cssls = {},
  -- cssmodules_ls = {}.
  eslint = {},
  graphql = {},
  html = {},
  -- TODO: if using jdtls get plugin
  -- https://github.com/mfussenegger/nvim-jdtls
  jdtls = {},
  jsonnet_ls = {},
  pyright = {},
  rust_analyzer = {},
  sqlls = {},
  stylelint_lsp = {},
  sumneko_lua = {
    Lua = {
      workspace = { checkThirdParty = false },
      telemetry = { enable = false },
    },
  },
  svelte = {},
  tailwindcss = {},
  tsserver = {},
}

-- list of available servers:
-- https://github.com/williamboman/mason-lspconfig.nvim#default-configuration
require("mason-lspconfig").setup {
  ensure_installed = vim.tbl_keys(servers),
  automatic_installation = true
}

require('mason-tool-installer').setup {
  ensure_installed = {
    "node-debug2-adapter",
    "eslint_d",
    "markdownlint",
    "prettier"
  },
  auto_update = true,
  run_on_start = true
}

-- LSP settings.
--  This function gets run when an LSP connects to a particular buffer.
local on_attach = function(_, bufnr)
  -- NOTE: Remember that lua is a real programming language, and as such it is possible
  -- to define small helper and utility functions so you don't have to repeat yourself
  -- many times.
  --
  -- In this case, we create a function that lets us more easily define mappings specific
  -- for LSP related items. It sets the mode, buffer and description for us each time.
  local nmap = function(keys, func, desc)
    if desc then
      desc = 'LSP: ' .. desc
    end

    vim.keymap.set('n', keys, func, { buffer = bufnr, desc = desc })
  end

  nmap('<leader>rn', vim.lsp.buf.rename, '[R]e[n]ame')
  nmap('<leader>ca', vim.lsp.buf.code_action, '[C]ode [A]ction')

  nmap('gd', vim.lsp.buf.definition, '[G]oto [D]efinition')
  nmap('gr', require('telescope.builtin').lsp_references, '[G]oto [R]eferences')
  nmap('gI', vim.lsp.buf.implementation, '[G]oto [I]mplementation')
  nmap('<leader>D', vim.lsp.buf.type_definition, 'Type [D]efinition')
  nmap('<leader>ds', require('telescope.builtin').lsp_document_symbols, '[D]ocument [S]ymbols')
  nmap('<leader>ws', require('telescope.builtin').lsp_dynamic_workspace_symbols, '[W]orkspace [S]ymbols')

  -- See `:help K` for why this keymap
  nmap('K', vim.lsp.buf.hover, 'Hover Documentation')
  nmap('<C-k>', vim.lsp.buf.signature_help, 'Signature Documentation')

  -- Lesser used LSP functionality
  nmap('gD', vim.lsp.buf.declaration, '[G]oto [D]eclaration')
  nmap('<leader>wa', vim.lsp.buf.add_workspace_folder, '[W]orkspace [A]dd Folder')
  nmap('<leader>wr', vim.lsp.buf.remove_workspace_folder, '[W]orkspace [R]emove Folder')
  nmap('<leader>wl', function()
    print(vim.inspect(vim.lsp.buf.list_workspace_folders()))
  end, '[W]orkspace [L]ist Folders')

  -- Create a command `:Format` local to the LSP buffer
  vim.api.nvim_buf_create_user_command(bufnr, 'Format', function(_)
    vim.lsp.buf.format()
  end, { desc = 'Format current buffer with LSP' })
end

local capabilities = vim.lsp.protocol.make_client_capabilities()
capabilities = require('cmp_nvim_lsp').default_capabilities(capabilities)
capabilities.textDocument.completion.completionItem.snippetSupport = true

require('mason-lspconfig').setup_handlers {
    function (server_name)
      require("lspconfig")[server_name].setup {
        capabilities = capabilities,
        on_attach = on_attach,
        settings = servers[server_name],
      }
    end
}

require('fidget').setup{}
