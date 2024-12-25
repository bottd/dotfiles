require('codecompanion').setup({
  strategies = {
    chat = {
      adapter = "anthropic"
    }
  },
  adapters = {
    anthropic = function()
      return require("codecompanion.adapters").extend("anthropic", {
        env = {
          api_key =
          "REMOVED"
        },
      })
    end,
  },
})

vim.keymap.set("n", "<leader>ac", ":CodeCompanionChat", { desc = "Chat" })
vim.keymap.set("n", "<leader>ad", ":CodeCompanionCommand", { desc = "Command" })
vim.keymap.set("n", "<leader>aa", ":CodeCompanionActions", { desc = "Actions" })

local which_key = require("which-key")

which_key.add({ { "<leader>a", desc = "AI" } })
