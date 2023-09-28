return {
  {
    'rose-pine/neovim',
    name = 'rose-pine',
    lazy = false,
    priority = 1000,
    dependencies = {
      'f-person/auto-dark-mode.nvim',
    },
    config = function()
      require("rose-pine").setup({
        dark_variant = "moon"
      })
      local auto_dark_mode = require('auto-dark-mode')
      auto_dark_mode.setup({
        update_interval = 1000,
        set_dark_mode = function()
        vim.api.nvim_set_option('background', 'dark')
        vim.cmd('colorscheme rose-pine')
      end,
      set_light_mode = function()
        vim.api.nvim_set_option('background', 'light')
        vim.cmd('colorscheme rose-pine')
      end,
      })
      auto_dark_mode.init()
    end
  },
  {
    'lukas-reineke/indent-blankline.nvim',
      main = "ibl",
      config = function()
        require("ibl").setup({
          indent = { char = "│" },
          scope = { enabled = true }
        })
      end,
      opts = {
        space_char_blankline = " ",
          show_current_context = true,
          show_current_context_start = true,

      }
  },
}
