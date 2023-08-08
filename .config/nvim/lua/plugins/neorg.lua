return {
  {
  "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim" },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = {}, -- Adds pretty icons to your documents
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
          ["core.tangle"] = {},
        },
      }
      vim.keymap.set('n', '<leader>ni', ':Neorg index<Cr>');
      vim.keymap.set('n', '<leader>nr', ':Neorg return<Cr>');
    end,
  }
}
