local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
return {
  {
    "nvim-neorg/neorg",
    build = ":Neorg sync-parsers",
    dependencies = { "nvim-lua/plenary.nvim", "nvim-neorg/neorg-telescope" },
    ft = "norg",
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
                [workspace] = workspace_path
              },
              default_workspace = workspace,
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
          ["core.itero"] = {},
          ["core.journal"] = {
            config = {
              journal_folder = "journals/daily",
              template_name = "meta/templates/journal.norg",
              strategy = "flat",
              workspace = workspace,
            },
          },
          ["core.summary"] = {},
          ["core.tangle"] = {},
        },
      }
    end,
    keys = {
      { mode = "n", "<leader>j", ":Neorg journal today<Cr>" },
      { mode = "n", "<leader>nj", ":Neorg journal<Cr>" },
      { mode = "n", "<leader>ni", ":Neorg index<Cr>" },
      { mode = "n", "<leader>nr", ":Neorg return<Cr>" },
    },
  }
}
