return {
  {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup()
      require('which-key').register({
        f = {
          name = "Find",
          f = { ":Telescope find_files<Cr>", "Find File" },
          s = { ":Telescope live_grep<Cr>", "Find String" },
          k = { ":Telescope keymaps<Cr>", "Find Keymap" },
          h = { ":Telescope help_tags<Cr>", "Find Help" },
        },
        n = "Neorg",
        u = { ":Telescope undo<Cr>", "Undo tree" },
        r = {
          r = { "<Plug>SnipRun<Cr>", "SnipRun Block"},
          o = { "<Plug>SnipRunOperator<Cr>", "SnipRun Operator"}
        },
      }, { prefix = "<leader>" })
    end
  },
}
