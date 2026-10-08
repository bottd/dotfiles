(set vim.o.background vim.g.stylix_appearance)
(match vim.g.stylix_theme
  :primer
  (if (= vim.g.stylix_appearance :light)
      (vim.cmd.colorscheme :github_light)
      (vim.cmd.colorscheme :github_dark))
  ;; melange picks light/dark off vim.o.background, set above
  :melange
  (vim.cmd.colorscheme :melange))
