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
        height = 24,
        width = 68
      },
      { icon = " ", title = "Projects", section = "projects", indent = 2, padding = 1 },
      { icon = " ", title = "Recent Files", section = "recent_files", indent = 2, padding = 1 },
    }
  },
  gitbrowse = { enabled = true },
  lazygit = { enabled = true },
  scroll = { enabled = true },
  styles = { zen = { backdrop = { transparent = false } } },
  zen = { enabled = true }
})

local wk = require("which-key")
wk.add({
  {
    "<leader>gg",
    function()
      Snacks.lazygit()
    end,
    desc = "Lazygit",
  },

  {
    "<leader>gw",
    function()
      Snacks.gitbrowse()
    end,
    desc = "Open in browser",
    icon = " "
  },
  {
    "<leader>wz",
    function()
      Snacks.zen()
    end,
    desc = "Zen mode",
    icon = "󱅻 "
  }
})
