local blink = require('blink.cmp')

blink.setup({
  keymap = { preset = "enter" },
  snippets = {
    expand = function(snippet) require('luasnip').lsp_expand(snippet) end,
    active = function(filter)
      if filter and filter.direction then
        return require('luasnip').jumpable(filter.direction)
      end
      return require('luasnip').in_snippet()
    end,
    jump = function(direction) require('luasnip').jump(direction) end,
  },
  sources = {
    default = { 'lsp', 'path', 'luasnip', 'buffer' },
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
