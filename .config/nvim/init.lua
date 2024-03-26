-- Rocks.nvim configuration from installer
-- local rocks_config = {
     -- rocks_path = "/Users/drakebott/.local/share/nvim/rocks",
     -- luarocks_binary = "/Users/drakebott/.local/share/nvim/rocks/bin/luarocks",
 -- }

-- luarocks --lua-version=5.1 --tree /Users/drakebott/.local/share/nvim/rocks --server='https://nvim-neorocks.github.io/rocks-binaries/' install rocks.nvim
 
 -- vim.g.rocks_nvim = rocks_config
 
 -- local luarocks_path = {
     -- vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?.lua"),
     -- vim.fs.joinpath(rocks_config.rocks_path, "share", "lua", "5.1", "?", "init.lua"),
 -- }
 -- package.path = package.path .. ";" .. table.concat(luarocks_path, ";")
 
 -- local luarocks_cpath = {
     -- vim.fs.joinpath(rocks_config.rocks_path, "lib", "lua", "5.1", "?.dylib"),
     -- vim.fs.joinpath(rocks_config.rocks_path, "lib64", "lua", "5.1", "?.dylib"),
 -- }
 -- package.cpath = package.cpath .. ";" .. table.concat(luarocks_cpath, ";")
 
 -- vim.opt.runtimepath:append(vim.fs.joinpath(rocks_config.rocks_path, "lib", "luarocks", "rocks-5.1", "rocks.nvim", "*"))

-- Image.nvim setup
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?/init.lua;"
package.path = package.path .. ";" .. vim.fn.expand("$HOME") .. "/.luarocks/share/lua/5.1/?.lua;"

require('plugin_manager');
-- loading lazy prevents rocks.nvim from loading
-- lazy loads plugins from /lua/plugins/*.lua files
require('lazy').setup('plugins')

require('general_config');

-- Copy to clipboard
vim.keymap.set('n', '<Leader>y', '"+y');

