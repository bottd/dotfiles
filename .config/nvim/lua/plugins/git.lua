-- [nfnl] Compiled from fnl/plugins/git.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  return (require("gitsigns")).setup()
end
return {{"lewis6991/gitsigns.nvim", config = _1_}, {"kdheepak/lazygit.nvim", cmd = {"LazyGit", "LazyGitConfig", "LazyGitCurrentFile", "LazyGitFilter", "LazyGitFilterCurrentFile"}, dependencies = {"nvim-lua/plenary.nvim"}, keys = {{"<leader>gg", ":LazyGit<cr>", mode = "n", desc = "LazyGit"}}}}
