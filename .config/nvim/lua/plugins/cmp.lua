-- [nfnl] Compiled from fnl/plugins/nvim-cmp.fnl by https://github.com/Olical/nfnl, do not edit.
local lsp_zero = require("lsp-zero")
local cmp = require("cmp")
local cmp_action = lsp_zero.cmp_action()
local cmp_autopairs = require("nvim-autopairs.completion.cmp")
lsp_zero.extend_cmp()
do end (cmp.event):on("confirm_done", cmp_autopairs.on_confirm_done())
return cmp.setup({formatting = lsp_zero.cmp_format(), mapping = cmp.mapping.preset.insert({["<C-Space>"] = cmp.mapping.complete(), ["<C-u>"] = cmp.mapping.scroll_docs(-4), ["<C-d>"] = cmp.mapping.scroll_docs(4), ["<C-f>"] = cmp_action.luasnip_jump_forward(), ["<C-b>"] = cmp_action.luasnip_jump_backward(), ["<CR>"] = cmp.mapping.confirm({select = true})}), sources = cmp.config.sources({{name = "copilot"}, {name = "nvim_lsp"}, {name = "conjure"}, {name = "path"}, {name = "luasnip"}, {name = "buffer"}, {name = "neorg"}})})
