-- [nfnl] Compiled from fnl/plugins/cmp.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  return (require("copilot")).setup({suggestion = {enabled = false}, panel = {enabled = false}})
end
local function _2_()
  return (require("copilot_cmp")).setup({method = "getCompletionsCycling"})
end
local function _3_()
  local lsp_zero = require("lsp-zero")
  local cmp = require("cmp")
  local cmp_action = lsp_zero.cmp_action()
  local cmp_autopairs = require("nvim-autopairs.completion.cmp")
  lsp_zero.extend_cmp()
  do end (cmp.event):on("confirm_done", cmp_autopairs.on_confirm_done())
  return cmp.setup({formatting = lsp_zero.cmp_format(), mapping = cmp.mapping.preset.insert({["<C-Space>"] = cmp.mapping.complete(), ["<C-u>"] = cmp.mapping.scroll_docs(-4), ["<C-d>"] = cmp.mapping.scroll_docs(4), ["<C-f>"] = cmp_action.luasnip_jump_forward(), ["<C-b>"] = cmp_action.luasnip_jump_backward(), ["<CR>"] = cmp.mapping.confirm({select = true})}), sources = cmp.config.sources({{name = "copilot"}, {name = "nvim_lsp"}, {name = "conjure"}, {name = "path"}, {name = "luasnip"}, {name = "buffer"}, {name = "neorg"}})})
end
return {"hrsh7th/nvim-cmp", event = "InsertEnter", dependencies = {"hrsh7th/cmp-nvim-lsp", "hrsh7th/cmp-buffer", "hrsh7th/cmp-path", "hrsh7th/cmp-cmdline", "L3MON4D3/LuaSnip", "rafamadriz/friendly-snippets", "f3fora/cmp-spell", "Olical/conjure", {"windwp/nvim-autopairs", event = "InsertEnter"}, {"zbirenbaum/copilot.lua", cmd = "Copilot", event = "InsertEnter", config = _1_}, {"zbirenbaum/copilot-cmp", config = _2_}}, config = _3_}
