require('plugin_manager');
-- lazy loads plugins from /lua/plugins/*.lua files
require('lazy').setup('plugins')

require('general_config');

-- Copy to clipboard
vim.keymap.set('n', '<Leader>y', '"+y');

