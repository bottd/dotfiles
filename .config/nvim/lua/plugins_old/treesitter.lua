-- [nfnl] Compiled from fnl/plugins/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local ts = require("nvim-treesitter.configs")
  return ts.setup({ensure_installed = {"comment", "css", "diff", "fennel", "fish", "gitignore", "graphql", "html", "json", "markdown", "markdown_inline", "norg", "lua", "python", "rust", "sql", "svelte", "toml", "tsx", "typescript", "vimdoc"}, autotag = {enable = true}, highlight = {enable = true}})
end
return {{"nvim-treesitter/nvim-treesitter", dependencies = {"windwp/nvim-ts-autotag", "nvim-treesitter/nvim-treesitter-context"}, build = ":TSUpdate", config = _1_}}
