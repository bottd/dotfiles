-- [nfnl] Compiled from fnl/plugins/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
local function _1_()
  local neorg = require("neorg")
  return neorg.setup({load = {["core.defaults"] = {}, ["core.concealer"] = {config = {}}, ["core.completion"] = {config = {engine = "nvim-cmp", name = "[Norg]"}}, ["core.dirman"] = {config = {workspaces = {[workspace] = workspace_path, inbox = (workspace_path .. "/inbox"), journals = (workspace_path .. "/journals"), meta = (workspace_path .. "/meta"), notes = (workspace_path .. "/notes"), public = (workspace_path .. "/public"), resources = (workspace_path .. "/resources"), scripts = (workspace_path .. "/scripts"), zettel = (workspace_path .. "/zettel")}, default_workspace = workspace}}, ["core.esupports.metagen"] = {config = {type = "auto"}}, ["core.export"] = {}, ["core.export.markdown"] = {config = {extensions = "all"}}, ["core.integrations.telescope"] = {}, ["core.integrations.nvim-cmp"] = {}, ["core.integrations.treesitter"] = {}, ["core.itero"] = {}, ["core.journal"] = {config = {journal_folder = "daily", template_name = "meta/templates/journal.norg", strategy = "flat", workspace = "journals"}}, ["core.summary"] = {}, ["core.tangle"] = {}, ["external.templates"] = {config = {templates_dir = (workspace_path .. "/meta/templates")}}}})
end
local function _2_()
  do
    local ed_width = vim.fn.winwidth("%")
    local ed_height = vim.fn.winwidth("%")
    local win_width = math.floor((ed_width * 0.6))
    local win_height = math.floor((ed_height * 0.8))
    local bufnr = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(bufnr, true, {width = win_width, height = win_height, row = ((ed_height - win_height) / 2), col = ((ed_width - win_width) / 2), relative = "editor", border = "rounded", title = "Daily Journal", title_pos = "center"})
  end
  return vim.api.nvim_command(":Neorg journal today")
end
return {"nvim-neorg/neorg", build = ":Neorg sync-parsers", dependencies = {"MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope", {"pysan3/neorg-templates", dependencies = {"L3MON4D3/LuaSnip"}}, {"lukas-reineke/headlines.nvim", config = true}}, ft = "norg", config = _1_, keys = {{"<leader>j", _2_, mode = "n", desc = "Journal"}, {"<leader>nj", ":Neorg journal<Cr>", mode = "n", desc = "Journal"}, {"<leader>ni", ":Neorg index<Cr>", mode = "n", desc = "Index"}, {"<leader>nf", ":Telescope neorg find_norg_files<Cr>", mode = "n", desc = "Find Norg"}, {"<leader>nt", ":Neorg tangle<Cr>", mode = "n", desc = ":Neorg tangle"}, {"<leader>nef", ":Neorg export to-file", mode = "n", desc = "Export file"}, {"<leader>ned", ":Neorg export directory", mode = "n", desc = "Export directory"}, {"<leader>nep", (":Neorg export directory " .. workspace_path .. "/public md<Cr>"), mode = "n", desc = "Export posts"}, {"<leader>nr", ":Neorg return<Cr>", mode = "n", desc = "Neorg"}}}
