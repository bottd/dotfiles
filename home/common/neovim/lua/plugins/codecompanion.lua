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
          -- TODO: Set api key in env, I just leaked my last api key :o
          api_key = os.getenv("ANTHROPIC_API_KEY")
        },
      })
    end,
  },
})

vim.keymap.set("n", "<leader>ac", ":CodeCompanionChat<CR>", { desc = "Chat" })
vim.keymap.set("n", "<leader>ad", ":CodeCompanionCommand<CR>", { desc = "Command" })
vim.keymap.set("n", "<leader>aa", ":CodeCompanionActions<CR>", { desc = "Actions" })

local which_key = require("which-key")

which_key.add({ { "<leader>a", desc = "AI" } })
