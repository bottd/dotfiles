-- Bootstrap Fennel for Awesome WM
-- This file loads fennel and then executes the main config

local fennel = require("fennel")

-- Add fennel to package searchers so we can require .fnl files
table.insert(package.searchers, fennel.searcher)

-- Add config directory to fennel path
local config_path = os.getenv("HOME") .. "/.config/awesome/?.fnl"
fennel.path = config_path .. ";" .. fennel.path

-- Load the main fennel config
require("init")
