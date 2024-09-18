-- [nfnl] Compiled from fnl/plugins/neorg.fnl by https://github.com/Olical/nfnl, do not edit.
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
local _local_1_ = require("neorg")
local setup = _local_1_["setup"]
local function _2_()
  local filename = vim.fn.expand("%:p:t:r")
  filename = filename:gsub("-", " ")
  local function _3_(first, rest)
    return (first:upper() .. rest:lower())
  end
  filename = filename:gsub("(%a)([%w_']*)", _3_)
  return filename
end
setup({load = {["core.defaults"] = {}, ["core.concealer"] = {config = {}}, ["core.dirman"] = {config = {workspaces = {[workspace] = workspace_path, Inbox = (workspace_path .. "/inbox"), Journals = (workspace_path .. "/journals"), Meta = (workspace_path .. "/meta"), Notes = (workspace_path .. "/notes"), Public = (workspace_path .. "/public"), Resources = (workspace_path .. "/resources"), Scripts = (workspace_path .. "/scripts"), Zettel = (workspace_path .. "/zettel")}, default_workspace = workspace}}, ["core.esupports.metagen"] = {config = {type = "auto", template = {{"title", _2_}, {"authors", "Drake Bott"}, {"created"}, {"updated"}, {"version"}}}}, ["core.export"] = {}, ["core.export.markdown"] = {config = {extensions = "all"}}, ["core.integrations.telescope"] = {}, ["core.integrations.treesitter"] = {}, ["core.itero"] = {}, ["core.journal"] = {config = {journal_folder = "daily", template_name = "meta/templates/journal.norg", strategy = "flat", workspace = "Journals"}}, ["core.summary"] = {}, ["core.tangle"] = {}, ["external.context"] = {}, ["external.templates"] = {config = {templates_dir = (workspace_path .. "/meta/templates")}}, ["external.interim-ls"] = {config = {completion_provider = {enable = true, categories = false}}}, ["external.worklog"] = {config = {default_workspace_title = "External"}}}})
local function _4_()
  do
    local win_width = math.floor((vim.o.columns * 0.6))
    local win_height = math.floor((vim.o.lines * 0.8))
    local buf = vim.api.nvim_create_buf(true, false)
    vim.api.nvim_open_win(buf, true, {width = win_width, height = win_height, row = ((vim.o.lines - win_height) / 2), col = ((vim.o.columns - win_width) / 2), relative = "editor", border = "rounded", title = "Daily Journal", title_pos = "center"})
  end
  return vim.api.nvim_command(":Neorg journal today")
end
vim.keymap.set("n", "<leader>j", _4_, {desc = "Journal"})
vim.keymap.set("n", "<leader>nj", ":Neorg journal<Cr>", {desc = "Journal"})
vim.keymap.set("n", "<leader>n<space>", ":Neorg index<Cr>", {desc = "Index"})
vim.keymap.set("n", "<leader>nif", "<Plug>(neorg.telescope.insert_file_link)", {desc = "Insert file link"})
vim.keymap.set("n", "<leader>nim", ":Neorg inject-metadata<Cr>", {desc = "Inject Metadata"})
vim.keymap.set("n", "<leader>nf", ":Telescope neorg find_norg_files<Cr>", {desc = "Find Norg"})
vim.keymap.set("n", "<leader>nt", ":Neorg tangle<Cr>", {desc = ":Neorg tangle"})
vim.keymap.set("n", "<leader>nef", ":Neorg export to-file", {desc = "Export file"})
vim.keymap.set("n", "<leader>ned", ":Neorg export directory", {desc = "Export directory"})
vim.keymap.set("n", "<leader>nep", (":Neorg export directory " .. workspace_path .. "/public md<Cr>"), {desc = "Export posts"})
vim.keymap.set("n", "<leader>nr", ":Neorg return<Cr>", {desc = "Neorg"})
local which_key = require("which-key")
return which_key.add({{"<leader>n", desc = "Neorg"}})
