local which_key = require("which-key")
local workspace = os.getenv("NEORG_WORKSPACE")
local workspace_path = os.getenv("NEORG_WORKSPACE_PATH")
require("neorg").setup({
  load = {
    ["core.defaults"] = {},
    ["core.concealer"] = { config = {} },
    ["core.completion"] = {
      config = {
        engine = {
          module_name = "external.lsp-completion",
        },
        name = "[Norg]",
      },
    },
    ["core.dirman"] = {
      config = {
        workspaces = {
          [workspace] = workspace_path,
          archive = (workspace_path .. "/archive"),
          inbox = (workspace_path .. "/inbox"),
          journals = (workspace_path .. "/journals"),
          meta = (workspace_path .. "/meta"),
          notes = (workspace_path .. "/notes"),
          public = (workspace_path .. "/public"),
          resources = (workspace_path .. "/resources"),
          scripts = (workspace_path .. "/scripts"),
          zettel = (workspace_path .. "/zettel"),
        },
        default_workspace = workspace,
      },
    },
    ["core.esupports.metagen"] = {
      config = {
        type = "auto",
        template = {
          {
            "title",
            function()
              local filename = vim.fn.expand("%:p:t:r")
              filename = filename:gsub("-", " ")
              filename = filename:gsub("(%a)([%w_']*)", function(first, rest)
                return (first:upper() .. rest:lower())
              end)
              return filename
            end,
          },
          { "authors", "Drake Bott" },
          { "created" },
          { "updated" },
          { "version" },
        },
      },
    },
    ["core.export"] = {},
    ["core.export.markdown"] = { config = { extensions = "all" } },
    ["core.integrations.telescope"] = {},
    ["core.integrations.treesitter"] = {},
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
    ["external.archive"] = {},
    ["external.context"] = {},
    -- ["external.query"] = {},
    ["external.templates"] = {
      config = {
        templates_dir = (workspace_path .. "/meta/templates"),
      }
    },
    ["external.interim-ls"] = {
      config = {
        completion_provider = {
          enable = true,
          categories = false,
        },
      },
    },
    ["external.worklog"] = {
      config = { default_workspace_title = "external" },
    },
  },
})
vim.keymap.set("n", "<leader>j", function()
  local win_width = math.floor(vim.o.columns * 0.6)
  local win_height = math.floor(vim.o.lines * 0.8)
  local buf = vim.api.nvim_create_buf(true, false)
  vim.api.nvim_open_win(buf, true, {
    width = win_width,
    height = win_height,
    row = ((vim.o.lines - win_height) / 2),
    col = ((vim.o.columns - win_width) / 2),
    relative = "editor",
    border = "rounded",
    title = "Daily Journal",
    title_pos = "center",
  })
  vim.api.nvim_command(":Neorg journal today")
end, { desc = "Journal" })
vim.keymap.set("n", "<leader>nj", ":Neorg journal<Cr>", { desc = "Journal" })
vim.keymap.set("n", "<leader>n<space>", ":Neorg index<Cr>", { desc = "Index" })

which_key.add({ { "<leader>ni", desc = "Insert" } })
vim.keymap.set("n", "<leader>nif", "<Plug>(neorg.telescope.insert_file_link)", { desc = "Insert file link" })
vim.keymap.set("n", "<leader>nim", ":Neorg inject-metadata<Cr>", { desc = "Inject metadata" })

which_key.add({ { "<leader>na", desc = "Archive" } })
vim.keymap.set("n", "<leader>naf", ":Neorg archive current-file<Cr>", { desc = "Archive file" })
vim.keymap.set("n", "<leader>nf", ":Telescope neorg find_norg_files<Cr>", { desc = "Find Norg" })
vim.keymap.set("n", "<leader>nt", ":Neorg tangle<Cr>", { desc = ":Neorg tangle" })

which_key.add({ { "<leader>ne", desc = "Export" } })
vim.keymap.set("n", "<leader>nef", ":Neorg export to-file", { desc = "Export file" })
vim.keymap.set("n", "<leader>ned", ":Neorg export directory", { desc = "Export directory" })
vim.keymap.set(
  "n",
  "<leader>nep",
  (":Neorg export directory " .. workspace_path .. "/public md<Cr>"),
  { desc = "Export posts" }
)
vim.keymap.set("n", "<leader>nr", ":Neorg return<Cr>", { desc = "Neorg" })

which_key.add({ { "<leader>n", desc = "Neorg" } })
