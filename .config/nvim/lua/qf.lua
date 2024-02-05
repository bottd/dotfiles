-- [nfnl] Compiled from fnl/qf.fnl by https://github.com/Olical/nfnl, do not edit.
local function quickf()
  local handle = io.popen("echo hello")
  local result = handle:read("*a")
  handle.close()
  return print(result)
end
return quickf()
