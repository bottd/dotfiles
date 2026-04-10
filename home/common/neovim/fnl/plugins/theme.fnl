(match vim.g.stylix_theme
  :oxocarbon (vim.cmd.colorscheme :oxocarbon)
  :one (let [onedark (require :onedark)]
         (onedark.setup {:style :light})
         (onedark.load)))
