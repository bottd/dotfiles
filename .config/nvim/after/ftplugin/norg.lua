vim.opt.conceallevel = 3
vim.api.nvim_command('set nonumber')
vim.api.nvim_command('set linebreak')
vim.api.nvim_command('set breakindent')

-- Disable nvim-tree keymaps
-- vim.keymap.del('n', '<C-n>')
-- vim.keymap.del('n', '<C-m>')


-- Todo grep copied from telescope readme update:
-- https://github.com/nvim-neorg/neorg-telescope/pull/47/files
do
    local _, neorg = pcall(require, "neorg.core")
    local dirman = neorg.modules.get_module("core.dirman")
    local function get_todos(dir, states)
        local current_workspace = dirman.get_current_workspace()
        local dir = current_workspace[2]
        require('telescope.builtin').live_grep{ cwd = dir }
        vim.fn.feedkeys('^ *([*]+|[-]+) +[(]' .. states .. '[)]')
    end

    -- This can be bound to a key
    vim.keymap.set('n', '<c-t>', function() get_todos('~/notes', '[^x_]') end)
end

-- Override telescope keymaps
vim.keymap.set('n', '<leader>ff', ':Telescope neorg find_norg_files<Cr>', { desc = "Find Norg Files"});
vim.keymap.set('n', '<leader>nw', ':Telescope neorg switch_workspace<Cr>', { desc = "Switch Workspace" });
