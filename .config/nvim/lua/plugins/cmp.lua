-- [nfnl] Compiled from fnl/plugins/cmp.fnl by https://github.com/Olical/nfnl, do not edit.
local lsp_zero = require("lsp-zero")
local cmp = require("cmp")
local cmp_action = lsp_zero.cmp_action()
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
lsp_zero.extend_cmp()
do end (cmp.event):on("confirm_done", cmp_autopairs.on_confirm_done())
local function _1_(args)
  local _local_2_ = require("luasnip")
  local lsp_expand = _local_2_["lsp_expand"]
  return lsp_expand(args.body)
end
return cmp.setup({snippet = {expand = _1_}, formatting = lsp_zero.cmp_format(), mapping = cmp.mapping.preset.insert({["<C-Space>"] = cmp.mapping.complete(), ["<C-u>"] = cmp.mapping.scroll_docs(-4), ["<C-d>"] = cmp.mapping.scroll_docs(4), ["<C-f>"] = cmp_action.luasnip_jump_forward(), ["<C-b>"] = cmp_action.luasnip_jump_backward(), ["<CR>"] = cmp.mapping.confirm({select = true})}), sources = cmp.config.sources({{name = "copilot"}, {name = "nvim_lsp"}, {name = "luasnip"}, {name = "conjure"}, {name = "path"}, {name = "buffer"}, {name = "neorg"}})})
