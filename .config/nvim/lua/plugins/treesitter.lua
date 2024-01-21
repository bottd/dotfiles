-- [nfnl] Compiled from fnl/plugins/treesitter.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  local ts = require("nvim-treesitter.configs")
  return ts.setup({ensure_installed = {"comment", "css", "diff", "fennel", "fish", "gitignore", "graphql", "html", "json", "markdown", "markdown_inline", "norg", "lua", "python", "rust", "sql", "svelte", "toml", "tsx", "typescript", "vimdoc"}, autotag = {enable = true}, highlight = {enable = true}})
end
local function _2_()
  local comment_nvim = require("Comment")
  local function _3_()
    local ts_comment_integration = require("ts_context_commentstring.integrations.comment_nvim")
    return ts_comment_integration.create_pre_hook()
  end
  return comment_nvim.setup({pre_hook = _3_})
end
return {{"nvim-treesitter/nvim-treesitter", dependencies = {"windwp/nvim-ts-autotag", "nvim-treesitter/nvim-treesitter-context"}, build = ":TSUpdate", config = _1_}, {"numToStr/Comment.nvim", dependencies = {"JoosepAlviste/nvim-ts-context-commentstring", "nvim-treesitter/nvim-treesitter"}, config = _2_}}
