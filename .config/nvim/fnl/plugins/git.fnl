[
  {
    1 :lewis6991/gitsigns.nvim
    :config (fn [] ((. (require :gitsigns) :setup)))
  }
  {
    1 :kdheepak/lazygit.nvim
    :cmd [
      :LazyGit
      :LazyGitConfig
      :LazyGitCurrentFile
      :LazyGitFilter
      :LazyGitFilterCurrentFile
    ]
    :dependencies [:nvim-lua/plenary.nvim]
    :keys [
      { 
        :mode "n"
        1 "<leader>gg"
        2 ":LazyGit<cr>"
        :desc "LazyGit"
      }
    ]
  }
]
