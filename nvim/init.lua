-- TODO: 
-- Install telescope
-- Configure tree sitter
-- Install nvim-cmp
require('plugins')
require('statusline')
require('theme')
require('completion')
require'mapx'.setup{ global = true }

nnoremap('<C-n>', ':NvimTreeToggle<Cr>')
