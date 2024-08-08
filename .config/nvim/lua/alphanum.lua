-- [nfnl] Compiled from fnl/alphanum.fnl by https://github.com/Olical/nfnl, do not edit.
local function path_to_filename(path)
  return path:match("^.+/(.+)$")
end
local function path_to_key(path)
  local filename = path_to_filename(path)
  local key = filename:match("^(.-)%-")
  if (key == nil) then
    key = filename:match("^(.-)%.")
  else
  end
  return key
end
local function key_to_list(path)
  local key = path_to_filename(path)
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
    local tbl_21_auto = {}
    local i_22_auto = 0
    for k, v in pairs(result) do
      local val_23_auto
      do
        local to_num = tonumber(v)
        if (to_num == nil) then
          val_23_auto = v
        else
          val_23_auto = to_num
        end
      end
      if (nil ~= val_23_auto) then
        i_22_auto = (i_22_auto + 1)
        tbl_21_auto[i_22_auto] = val_23_auto
      else
      end
    end
    result = tbl_21_auto
  end
  return result
end
local function an_compare(a, b)
  do
    local _7_ = {a, b}
    local and_8_ = ((_G.type(_7_) == "table") and (nil ~= _7_[1]) and (nil ~= _7_[2]))
    if and_8_ then
      local x = _7_[1]
      local y = _7_[2]
      and_8_ = string.find(x, "index.norg")
    end
    if and_8_ then
      local x = _7_[1]
      local y = _7_[2]
      return false
    else
      local and_10_ = ((_G.type(_7_) == "table") and (nil ~= _7_[1]) and (nil ~= _7_[2]))
      if and_10_ then
        local x = _7_[1]
        local y = _7_[2]
        and_10_ = string.find(y, "index.norg")
      end
      if and_10_ then
        local x = _7_[1]
        local y = _7_[2]
        return true
      else
      end
    end
  end
  local a_id = path_to_filename(a)
  local b_id = path_to_filename(b)
  local a_keys = key_to_list(a)
  local b_keys = key_to_list(b)
  local result = nil
  for k, a_val in pairs(a_keys) do
    if not (result == nil) then break end
    local b_val = b_keys[k]
    local _13_ = {a_val, b_val}
    if ((_G.type(_13_) == "table") and (nil ~= _13_[1]) and (_13_[1] == _13_[2])) then
      local x = _13_[1]
      result = nil
    elseif ((_G.type(_13_) == "table") and (nil ~= _13_[1]) and (_13_[2] == nil)) then
      local x = _13_[1]
      result = false
    elseif ((_G.type(_13_) == "table") and (_13_[1] == nil) and (nil ~= _13_[2])) then
      local y = _13_[2]
      result = true
    else
      local and_14_ = ((_G.type(_13_) == "table") and (nil ~= _13_[1]) and (nil ~= _13_[2]))
      if and_14_ then
        local x = _13_[1]
        local y = _13_[2]
        and_14_ = (x > y)
      end
      if and_14_ then
        local x = _13_[1]
        local y = _13_[2]
        result = false
      else
        local and_16_ = ((_G.type(_13_) == "table") and (nil ~= _13_[1]) and (nil ~= _13_[2]))
        if and_16_ then
          local x = _13_[1]
          local y = _13_[2]
          and_16_ = (x < y)
        end
        if and_16_ then
          local x = _13_[1]
          local y = _13_[2]
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
return {["an-compare"] = an_compare}
