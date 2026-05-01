(set vim.o.background vim.g.stylix_appearance)
(match vim.g.stylix_theme
  :oxocarbon (vim.cmd.colorscheme :oxocarbon)
  :primer-light (vim.cmd.colorscheme :github_light))
