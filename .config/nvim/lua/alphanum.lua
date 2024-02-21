-- [nfnl] Compiled from fnl/alphanum.fnl by https://github.com/Olical/nfnl, do not edit.
local function file_to_key(filename)
  local key = filename:match("^(.-)%-")
  if (key == nil) then
    key = filename:match("^(.-)%.")
  else
  end
  return key
end
local function key_to_list(filename)
  if (filename == "index.norg") then
    return {0}
  else
  end
  local key = file_to_key(filename)
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
  for k, a_val in pairs(a.keys) do
    if not (result == nil) then break end
    local b_val = b.keys[k]
    local _8_ = {a_val, b_val}
    if ((_G.type(_8_) == "table") and (nil ~= (_8_)[1]) and ((_8_)[1] == (_8_)[2])) then
      local x = (_8_)[1]
      result = nil
    elseif ((_G.type(_8_) == "table") and (nil ~= (_8_)[1]) and ((_8_)[2] == nil)) then
      local x = (_8_)[1]
      result = false
    elseif ((_G.type(_8_) == "table") and ((_8_)[1] == nil) and (nil ~= (_8_)[2])) then
      local y = (_8_)[2]
      result = true
    else
      local function _9_()
        local x = (_8_)[1]
        local y = (_8_)[2]
        return (x > y)
      end
      if (((_G.type(_8_) == "table") and (nil ~= (_8_)[1]) and (nil ~= (_8_)[2])) and _9_()) then
        local x = (_8_)[1]
        local y = (_8_)[2]
        result = false
      else
        local function _10_()
          local x = (_8_)[1]
          local y = (_8_)[2]
          return (x < y)
        end
        if (((_G.type(_8_) == "table") and (nil ~= (_8_)[1]) and (nil ~= (_8_)[2])) and _10_()) then
          local x = (_8_)[1]
          local y = (_8_)[2]
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
local function an_srt(items)
  local result
  do
    local tbl_17_auto = {}
    local i_18_auto = #tbl_17_auto
    for k, v in pairs(items) do
      local val_19_auto = {keys = key_to_list(v), id = v}
      if (nil ~= val_19_auto) then
        i_18_auto = (i_18_auto + 1)
        do end (tbl_17_auto)[i_18_auto] = val_19_auto
      else
      end
    end
    result = tbl_17_auto
  end
  table.sort(result, an_compare)
  return result
end
return {an_srt = an_srt, an_compare = an_compare}
