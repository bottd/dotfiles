-- [nfnl] Compiled from fnl/plugins/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
do
  local neorg = require("neorg")
  neorg.setup({load = {["core.defaults"] = {}, ["core.concealer"] = {config = {}}, ["core.completion"] = {config = {engine = "nvim-cmp", name = "[Norg]"}}, ["core.dirman"] = {config = {workspaces = {[workspace] = workspace_path, inbox = (workspace_path .. "/inbox"), journals = (workspace_path .. "/journals"), meta = (workspace_path .. "/meta"), notes = (workspace_path .. "/notes"), public = (workspace_path .. "/public"), resources = (workspace_path .. "/resources"), scripts = (workspace_path .. "/scripts"), zettel = (workspace_path .. "/zettel")}, default_workspace = workspace}}, ["core.export"] = {}, ["core.export.markdown"] = {config = {extensions = "all"}}, ["core.integrations.telescope"] = {}, ["core.integrations.nvim-cmp"] = {}, ["core.integrations.treesitter"] = {}, ["core.itero"] = {}, ["core.journal"] = {config = {journal_folder = "daily", template_name = "meta/templates/journal.norg", strategy = "flat", workspace = "journals"}}, ["core.summary"] = {}, ["core.tangle"] = {}, ["external.templates"] = {config = {templates_dir = (workspace_path .. "/meta/templates")}}}})
end
local function _1_()
  do
    local win_width = math.floor((vim.o.columns * 0.6))
    local win_height = math.floor((vim.o.lines * 0.8))
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, {width = win_width, height = win_height, row = ((vim.o.lines - win_height) / 2), col = ((vim.o.columns - win_width) / 2), relative = "editor", border = "rounded", title = "Daily Journal", title_pos = "center"})
  end
  return vim.api.nvim_command(":Neorg journal today")
end
vim.keymap.set("n", "<leader>j", _1_, {desc = "Journal"})
vim.keymap.set("n", "<leader>nj", ":Neorg journal<Cr>", {desc = "Journal"})
vim.keymap.set("n", "<leader>ni", ":Neorg index<Cr>", {desc = "Index"})
vim.keymap.set("n", "<leader>nmi", ":Neorg inject-metadata<Cr>", {desc = "Inject Metadata"})
vim.keymap.set("n", "<leader>nf", ":Telescope neorg find_norg_files<Cr>", {desc = "Find Norg"})
vim.keymap.set("n", "<leader>nt", ":Neorg tangle<Cr>", {desc = ":Neorg tangle"})
vim.keymap.set("n", "<leader>nef", ":Neorg export to-file", {desc = "Export file"})
vim.keymap.set("n", "<leader>ned", ":Neorg export directory", {desc = "Export directory"})
vim.keymap.set("n", "<leader>nep", (":Neorg export directory " .. workspace_path .. "/public md<Cr>"), {desc = "Export posts"})
vim.keymap.set("n", "<leader>nr", ":Neorg return<Cr>", {desc = "Neorg"})
return vim.keymap.set("n", "<leader>nz", get_sorted_zettel, {desc = "Get Zettels"})
