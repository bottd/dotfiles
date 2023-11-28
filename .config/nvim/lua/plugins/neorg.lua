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
            config = {

            }
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
                [workspace] = workspace_path,
                inbox = workspace_path .. "/inbox",
                journals = workspace_path .. "/journals",
                meta = workspace_path .. "/meta",
                notes = workspace_path .. "/notes",
                resources = workspace_path .. "/resources",
                scripts = workspace_path .. "/scripts",
                zettel = workspace_path .. "/zettel",
              },
              default_workspace = workspace
            },
          },
          ["core.esupports.metagen"] = {
            config = {
              type = "auto",
            }
          },
          ["core.export"] = {},
          ["core.export.markdown"] = {
            config = {
              extensions = "all"
            }
          },
          ["core.integrations.telescope"] = {},
          ["core.integrations.nvim-cmp"] = {},
          ["core.integrations.treesitter"] = {},
          ["core.integrations.zen_mode"] = {},
          ["core.itero"] = {},
          ["core.journal"] = {
            config = {
              journal_folder = "daily",
              template_name = "meta/templates/journal.norg",
              strategy = "flat",
              workspace = "journals",
            },
          },
          ["core.summary"] = {},
          ["core.tangle"] = {},
        },
      }
    end,
    keys = {
      {
        mode = "n",
        "<leader>j",
        ":Neorg journal today<Cr>",
        desc = "Journal"
      },
      {
        mode = "n",
        "<leader>nj",
        ":Neorg journal<Cr>",
        desc = "Journal"
      },
      {
        mode = "n",
        "<leader>ni",
        ":Neorg index<Cr>",
        desc = "Index"
      },
      {
        mode = "n",
        "<leader>nf",
        ":Telescope neorg find_norg_files<Cr>",
        desc = "Find Norg"
      },
      {
        mode = "n",
        "<leader>nr",
        ":Neorg return<Cr>",
        desc = "Neorg"
      },
    },
  }
}
