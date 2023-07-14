require('general_config');
require('plugin_manager');
-- lazy loads plugins from /lua/plugins/*.lua files
require('lazy').setup('plugins')

-- Copy to clipboard
vim.keymap.set('n', '<Leader>y', '"+y');

