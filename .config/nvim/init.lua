-- TODO: 
-- Install telescope
-- Configure tree sitter
-- Install nvim-cmp
require('plugins');
require'mapx'.setup{ global = true }
require('default_settings');
require('statusline');
require('filetree');
require('theme');
require('completion');
require('git');
require('lsp_config');
require('telescope_config');
require('treesitter_config');
