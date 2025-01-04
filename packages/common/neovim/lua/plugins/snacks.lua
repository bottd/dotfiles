local snacks = require("snacks")
snacks.setup({
  bigfile = { enabled = true },
  dashboard = {
    enabled = true,
    preset = {
      pick = "telsecope.nvim",
    },
    sections = {
      {
        section = "terminal",
        cmd = "fortune | cowsay -f stegosaurus",
        hl = "header",
        height = 20,
        width = 68
      },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    }
  },
})
