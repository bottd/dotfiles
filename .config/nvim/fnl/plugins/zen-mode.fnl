(let [zen-mode (require :zen-mode)]
  (zen-mode.setup {
    :plugins {
      :wezterm {
        :enabled true
      }
    }
  }))

(vim.keymap.set
  "n" 
  "<leader>wz"
  ":ZenMode<Cr>"
  { :desc "Zen Mode" })
