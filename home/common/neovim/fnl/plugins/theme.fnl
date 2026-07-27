(set vim.o.background vim.g.stylix_appearance)
(match vim.g.stylix_theme
  :catppuccin (if (= vim.g.stylix_appearance :light)
                  (vim.cmd.colorscheme :catppuccin-latte)
                  (vim.cmd.colorscheme :catppuccin-mocha))
  :primer (if (= vim.g.stylix_appearance :light)
              (vim.cmd.colorscheme :github_light)
              (vim.cmd.colorscheme :github_dark)))
