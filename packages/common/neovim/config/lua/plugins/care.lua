local nvim_autopairs = require("nvim-autopairs")
nvim_autopairs.setup()

local care = require("care")
care.setup({
  ui = {
    ghost_text = { position = "inline" },
    menu = {
      max_height = 10,
      border = {
        { "▄", "@care.menu" },
        { "▄", "@care.menu" },
        { "▄", "@care.menu" },
        { "█", "@care.menu" },
        { "▀", "@care.menu" },
        { "▀", "@care.menu" },
        { "▀", "@care.menu" },
        { "█", "@care.menu" },
      },
      format_entry = function(entry, data)
        local components = require("care.presets.components")
        local completion_item = entry.completion_item
        local entry_kind = type(completion_item.kind) == "string" and completion_item.kind
            or require("care.utils.lsp").get_kind_name(completion_item.kind)
        function SourceName()
          return { { data.source_name, ("@care.type.fg.%s"):format(entry_kind) } }
        end

        return {
          components.KindIcon(entry, "fg"),
          components.Label(entry, data, true),
          SourceName(),
        }
      end,
    },
  },
  alignment = { "left", "right" },
  selection_behavior = "insert",
  confirm_behavior = "replace",
  sorting_direction = "away-from-cursor",
  sources = {
    lsp = { max_entries = 5, priority = 1 },
    cmp_buffer = { max_entries = 3 },
  },
  snippet_expansion = function(body)
    require("luasnip").lsp_expand(body)
  end,
})

vim.keymap.set("i", "<Cr>", "<Plug>(CareConfirm)")
vim.keymap.set("i", "<c-e>", "<Plug>(CareClose)")
vim.keymap.set("i", "<c-n>", "<Plug>(CareSelectNext)")
vim.keymap.set("i", "<c-p>", "<Plug>(CareSelectPrev)")
