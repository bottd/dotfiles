-- [nfnl] Compiled from fnl/plugins/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
local _local_1_ = require("../zk")
local get_sorted_zettel = _local_1_["get_sorted_zettel"]
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
local function _2_()
  local neorg = require("neorg")
  return neorg.setup({load = {["core.defaults"] = {}, ["core.concealer"] = {config = {}}, ["core.completion"] = {config = {engine = "nvim-cmp", name = "[Norg]"}}, ["core.dirman"] = {config = {workspaces = {[workspace] = workspace_path, inbox = (workspace_path .. "/inbox"), journals = (workspace_path .. "/journals"), meta = (workspace_path .. "/meta"), notes = (workspace_path .. "/notes"), public = (workspace_path .. "/public"), resources = (workspace_path .. "/resources"), scripts = (workspace_path .. "/scripts"), zettel = (workspace_path .. "/zettel")}, default_workspace = workspace}}, ["core.export"] = {}, ["core.export.markdown"] = {config = {extensions = "all"}}, ["core.integrations.telescope"] = {}, ["core.integrations.nvim-cmp"] = {}, ["core.integrations.treesitter"] = {}, ["core.itero"] = {}, ["core.journal"] = {config = {journal_folder = "daily", template_name = "meta/templates/journal.norg", strategy = "flat", workspace = "journals"}}, ["core.summary"] = {}, ["core.tangle"] = {}, ["external.templates"] = {config = {templates_dir = (workspace_path .. "/meta/templates")}}}})
end
local function _3_()
  do
    local win_width = math.floor((vim.o.columns * 0.6))
    local win_height = math.floor((vim.o.lines * 0.8))
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, {width = win_width, height = win_height, row = ((vim.o.lines - win_height) / 2), col = ((vim.o.columns - win_width) / 2), relative = "editor", border = "rounded", title = "Daily Journal", title_pos = "center"})
  end
  return vim.api.nvim_command(":Neorg journal today")
end
return {{"vhyrro/luarocks.nvim", priority = 1000, config = true}, {"lukas-reineke/headlines.nvim", config = true}, {"nvim-neorg/neorg", dependencies = {"vhyrro/luarocks.nvim", "MunifTanjim/nui.nvim", "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope", {"pysan3/neorg-templates", dependencies = {"L3MON4D3/LuaSnip"}}}, ft = "norg", config = _2_, keys = {{"<leader>j", _3_, mode = "n", desc = "Journal"}, {"<leader>nj", ":Neorg journal<Cr>", mode = "n", desc = "Journal"}, {"<leader>ni", ":Neorg index<Cr>", mode = "n", desc = "Index"}, {"<leader>nmi", ":Neorg inject-metadata<Cr>", mode = "n", desc = "Inject Metadata"}, {"<leader>nf", ":Telescope neorg find_norg_files<Cr>", mode = "n", desc = "Find Norg"}, {"<leader>nt", ":Neorg tangle<Cr>", mode = "n", desc = ":Neorg tangle"}, {"<leader>nef", ":Neorg export to-file", mode = "n", desc = "Export file"}, {"<leader>ned", ":Neorg export directory", mode = "n", desc = "Export directory"}, {"<leader>nep", (":Neorg export directory " .. workspace_path .. "/public md<Cr>"), mode = "n", desc = "Export posts"}, {"<leader>nr", ":Neorg return<Cr>", mode = "n", desc = "Neorg"}, {"<leader>nz", get_sorted_zettel, mode = "n", desc = "Get Zettels"}}}}
