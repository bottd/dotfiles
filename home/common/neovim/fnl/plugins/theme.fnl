(set vim.o.background vim.g.stylix_appearance)
(match vim.g.stylix_theme
  :tokyo-night (if (= vim.g.stylix_appearance :light)
                   (vim.cmd.colorscheme :tokyonight-day)
                   (vim.cmd.colorscheme :tokyonight-night))
  :primer (if (= vim.g.stylix_appearance :light)
              (vim.cmd.colorscheme :github_light)
              (vim.cmd.colorscheme :github_dark)))
