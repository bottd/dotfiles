return {
    'tamton-aquib/duck.nvim',
    config = function()
        vim.keymap.set('n', '<leader>dd', function() require("duck").hatch() end, {})
        vim.keymap.set('n', '<leader>dk', function() require("duck").cook() end, {})
    end
}
