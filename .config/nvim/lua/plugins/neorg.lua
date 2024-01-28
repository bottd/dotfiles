-- [nfnl] Compiled from fnl/plugins/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
local function _1_()
  local neorg = require("neorg")
  return neorg.setup({load = {["core.defaults"] = {}, ["core.concealer"] = {config = {}}, ["core.completion"] = {config = {engine = "nvim-cmp", name = "[Norg]"}}, ["core.dirman"] = {config = {workspaces = {[workspace] = workspace_path, inbox = (workspace_path .. "/inbox"), journals = (workspace_path .. "/journals"), meta = (workspace_path .. "/meta"), notes = (workspace_path .. "/notes"), public = (workspace_path .. "/public"), resources = (workspace_path .. "/resources"), scripts = (workspace_path .. "/scripts"), zettel = (workspace_path .. "/zettel")}, default_workspace = workspace}}, ["core.esupports.metagen"] = {config = {type = "auto"}}, ["core.export"] = {}, ["core.export.markdown"] = {config = {extensions = "all"}}, ["core.integrations.telescope"] = {}, ["core.integrations.nvim-cmp"] = {}, ["core.integrations.treesitter"] = {}, ["core.integrations.zen_mode"] = {}, ["core.itero"] = {}, ["core.journal"] = {config = {journal_folder = "daily", template_name = "meta/templates/journal.norg", strategy = "flat", workspace = "journals"}}, ["core.summary"] = {}, ["core.tangle"] = {}, ["external.templates"] = {config = {templates_dir = (workspace_path .. "/meta/templates")}}}})
end
return {"nvim-neorg/neorg", build = ":Neorg sync-parsers", dependencies = {"MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope", {"pysan3/neorg-templates", dependencies = {"L3MON4D3/LuaSnip"}}}, ft = "norg", config = _1_, keys = {{"<leader>j", ":Neorg journal today<Cr>", mode = "n", desc = "Journal"}, {"<leader>nj", ":Neorg journal", mode = "n", desc = "Journal"}, {"<leader>ni", ":Neorg index<Cr>", mode = "n", desc = "Index"}, {"<leader>nf", ":Telescope neorg find_norg_files<Cr>", mode = "n", desc = "Find Norg"}, {"<leader>nt", ":Neorg tangle<Cr>", mode = "n", desc = ":Neorg tangle"}, {"<leader>nef", ":Neorg export to-file", mode = "n", desc = "Export file"}, {"<leader>ned", ":Neorg export directory", mode = "n", desc = "Export directory"}, {"<leader>nep", (":Neorg export directory " .. workspace_path .. "/public md<Cr>"), mode = "n", desc = "Export posts"}, {"<leader>nr", ":Neorg return<Cr>", mode = "n", desc = "Neorg"}}}
