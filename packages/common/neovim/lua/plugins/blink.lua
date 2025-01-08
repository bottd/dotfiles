require("blink.cmp").setup({
  keymap = { preset = "super-tab" },
  snippets = {
    preset = 'luasinp',
  },
  sources = {
    default = { 'lsp', 'path', 'snippets', 'buffer', 'codecompanion' },
    providers = {
      codecompanion = {
        name = "CodeCompanion",
        module = "codecompanion.providers.completion.blink",
        enabled = true,
      },
    },
  },
  completion = {
    keyword = {
      range = 'prefix',
    },
    list = {
      selection = 'preselect',
      cycle = {
        from_bottom = true,
        from_top = true,
      },
    },
    accept = {
      create_undo_point = true,
      auto_brackets = {
        enabled = true,
        kind_resolution = {
          enabled = true,
        },
        semantic_token_resolution = {
          enabled = true,
        },
      },
    },

    menu = {
      border = 'padded',
      draw = {
        padding = 1,
        gap = 1,
        treesitter = { 'lsp' },
        columns = {
          { 'kind_icon' },
          { 'label',      'label_description', gap = 1 },
          { 'source_name' }
        },
      },
    },

    documentation = {
      auto_show = true,
      window = {
        border = 'padded',
        scrollbar = true,
      },
    },

    ghost_text = {
      enabled = false,
    },
  }
})
