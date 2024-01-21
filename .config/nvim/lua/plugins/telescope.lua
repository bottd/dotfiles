-- [nfnl] Compiled from fnl/plugins/telescope.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local telescope = require("telescope")
  telescope.setup({pickers = {find_files = {layout_strategy = "vertical"}, live_grep = {layout_strategy = "vertical"}}, extensions = {fzf = {fuzzy = true, override_generic_sorter = true, override_file_sorter = true, case_mode = "smart_case"}, undo = {use_delta = true}}})
  telescope.load_extension("fzf")
  return telescope.load_extension("undo")
end
return {"nvim-telescope/telescope.nvim", dependencies = {"debugloop/telescope-undo.nvim", {"nvim-telescope/telescope-fzf-native.nvim", build = "arch -arm64 make"}}, config = _1_, keys = {{"<leader>fb", ":Telescope buffers<Cr>", mode = "n", desc = "Find Buffer"}, {"<leader>ff", ":Telescope find_files<Cr>", mode = "n", desc = "Find Files"}, {"<leader>fs", ":Telescope live_grep<Cr>", mode = "n", desc = "Find String"}, {"<leader>fk", ":Telescope keymaps<Cr>", mode = "n", desc = "Find Keymap"}, {"<leader>fh", ":Telescope help_tags<Cr>", mode = "n", desc = "Find Help"}, {"<leader>fu", ":Telescope undo<Cr>", mode = "n", desc = "Undo Tree"}}}
