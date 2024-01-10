return {
  {
    'folke/which-key.nvim',
    config = function()
      vim.o.timeout = true
      vim.o.timeoutlen = 300
      require('which-key').setup()
      require('which-key').register({
        e = "Evaluate [Conjure]",
        f = {
          name = "Find",
        },
        l = "Log [Conjure]",
        n = "Neorg",
      }, { prefix = "<leader>" })
    end
  },
}
