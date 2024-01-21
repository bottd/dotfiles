-- [nfnl] Compiled from fnl/plugins/git.fnl by https://github.com/Olical/nfnl, do not edit.
local function _1_()
  return (require("gitsigns")).setup()
end
return {"lewis6991/gitsigns.nvim", config = _1_}
