return {
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
    config = function()
      require("neorg").setup {
        load = {
          ["core.defaults"] = {}, -- Loads default behaviour
          ["core.concealer"] = { -- Adds pretty icons to your documents
            config = {}
          },
          ["core.completion"] = {
            config = {
              engine = "nvim-cmp",
              name = "[Norg]",
            },
          },
          ["core.dirman"] = { -- Manages Neorg workspaces
            config = {
              workspaces = {
                notes = "~/notes",
              },
              default_workspace = "notes",
            },
          },
          ["core.esupports.metagen"] = {
            config = {
              type = "auto",
            }
          },
          ["core.export"] = {},
          ["core.export.markdown"] = {},
          ["core.integrations.telescope"] = {},
          ["core.integrations.nvim-cmp"] = {},
          ["core.integrations.treesitter"] = {},
          ["core.journal"] = {
            config = {
              journal_folder = "journals",
              strategy = "flat",
              workspace = "notes",
            },
          },
          ["core.qol.toc"] = {},
          ["core.qol.todo_items"] = {},
          ["core.tangle"] = {},
        },
      }
    end,
    keys = {
      { mode = "n", "<leader>nj", ":Neorg journal<Cr>" },
      { mode = "n", "<leader>ni", ":Neorg index<Cr>" },
      { mode = "n", "<leader>nr", ":Neorg return<Cr>" },
    },
  }
}