{1 :folke/zen-mode.nvim
  :opts {
    :plugins {
      :wezterm {
        :enabled true
      }
    }
  }
  :keys [
    { 
      :mode "n" 
      1 "<leader>wz"
      2 ":ZenMode<Cr>"
      :desc "Zen Mode"
    }
  ]
}
