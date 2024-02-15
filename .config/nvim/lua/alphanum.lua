-- [nfnl] Compiled from fnl/alphanum.fnl by https://github.com/Olical/nfnl, do not edit.
local function key_to_list(key)
  local result = {string.sub(key, 0, 0)}
  local curr_type = "num"
  for i = 1, #key do
    local len = #result
    local k = string.sub(key, i, i)
    local k_type = ""
    if (tonumber(k) == nil) then
      k_type = "alpha"
    else
      k_type = "num"
    end
    if (k_type == curr_type) then
      local item = result[len]
      result[len] = (item .. k)
    else
    end
    if not (k_type == curr_type) then
      table.insert(result, k)
      curr_type = k_type
    else
    end
  end
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for k, v in pairs(result) do
      local val_19_auto
      do
        local to_num = tonumber(v)
        if (to_num == nil) then
          val_19_auto = v
        else
          val_19_auto = to_num
        end
      end
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    result = tbl_17_auto
  end
  return result
end
local function an_compare(a, b)
  local result = nil
  local a_keys = key_to_list(a)
  local b_keys = key_to_list(b)
  for k, a_val in pairs(a_keys) do
    if not (result == nil) then break end
    local b_val = b_keys[k]
    local _6_ = {a_val, b_val}
    if ((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and ((_6_)[2] == nil)) then
      local x = (_6_)[1]
      result = false
    elseif ((_G.type(_6_) == "table") and ((_6_)[1] == nil) and (nil ~= (_6_)[2])) then
      local y = (_6_)[2]
      result = true
    else
      local function _7_()
        local x = (_6_)[1]
        local y = (_6_)[2]
        return (x > y)
      end
      if (((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and (nil ~= (_6_)[2])) and _7_()) then
        local x = (_6_)[1]
        local y = (_6_)[2]
        result = false
      else
        local function _8_()
          local x = (_6_)[1]
          local y = (_6_)[2]
          return (x < y)
        end
        if (((_G.type(_6_) == "table") and (nil ~= (_6_)[1]) and (nil ~= (_6_)[2])) and _8_()) then
          local x = (_6_)[1]
          local y = (_6_)[2]
          result = true
        else
        end
      end
    end
  end
  if (result == nil) then
    result = false
  else
  end
  return result
end
return {an_compare = an_compare}
