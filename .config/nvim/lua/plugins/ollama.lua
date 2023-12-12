return {
  "dustinblackman/oatmeal.nvim",
  cmd = { "Oatmeal" },
  keys = {
    { "<leader>om", mode = "n", desc = "Start Oatmeal session" },
  },
  opts = {
    backend = "ollama",
    model = "mistral:latest",
  }
}
