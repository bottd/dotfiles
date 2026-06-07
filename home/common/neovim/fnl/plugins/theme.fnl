(set vim.o.background vim.g.stylix_appearance)
(match vim.g.stylix_theme
  :everforest (let [everforest (require :everforest)]
                (everforest.setup {:background :medium})
                (vim.cmd.colorscheme :everforest))
  :primer-light (vim.cmd.colorscheme :github_light))
