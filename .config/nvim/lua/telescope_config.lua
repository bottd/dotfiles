-- You dont need to set any of these options. These are the default ones. Only
-- the loading is important
require('telescope').setup {
  pickers = {
    find_files = {
      layout_strategy = 'vertical'
    },
    live_grep = {
      layout_strategy = 'vertical'
    },
  },
  extensions = {
    fzf = {
      fuzzy = true,
      override_generic_sorter = true,
      override_file_sorter = true,
      case_mode = "smart_case",
    },
    undo = {
      use_delta = true
    }
  }
}

-- load telescope extensions
require('telescope').load_extension('fzf')
require('telescope').load_extension('undo')

vim.keymap.set('n', '<leader>ff', ':Telescope find_files<Cr>');
vim.keymap.set('n', '<leader>fs', ':Telescope live_grep<Cr>');
vim.keymap.set('n', '<leader>fk', ':Telescope keymaps<Cr>');
vim.keymap.set('n', '<leader>fh', ':Telescope help_tags<Cr>');
vim.keymap.set('n', '<leader>u', ':Telescope undo<Cr>');
