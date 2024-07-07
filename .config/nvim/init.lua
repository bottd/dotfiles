-- Rocks.nvim configuration from installer
 local rocks_config = {
     rocks_path = vim.env.HOME .. "/.local/share/nvim/rocks",
     luarocks_config = {
      arch = "macosx-aarch64"
     }
 }

 vim.g.rocks_nvim = rocks_config

 local luarocks_path = {
     vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
     vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
 }
 package.path = package.path .. ";" .. table.concat(luarocks_path, ";")
 
 local luarocks_cpath = {
     vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.so"),
     vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.so"),
     -- Remove the dylib and dll paths if you do not need macos or windows support
     vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.dylib"),
     vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.dylib"),
     vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.dll"),
     vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.dll"),
 }
 package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")
 
 vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))

-- Image.nvim setup
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
-- package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"
-- vim.cmd([[packadd rocks-dev.nvim]])

require('general_config');
