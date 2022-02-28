-- TODO: 
-- Install telescope
-- Configure tree sitter
-- Install nvim-cmp
require('plugins');
require'mapx'.setup{ global = true }
require('default_settings');
require('statusline');
require('theme');
require('completion');
require('git');
require('telescope_config');
require('treesitter_config');
