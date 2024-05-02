((. (require :rose-pine) :setup) { :dark_variant "moon" })
(vim.cmd "colorscheme rose-pine")

;; window_appearance is set in wezterm config
(let [appearance (os.getenv :WINDOW_APPEARANCE)]
  (when (= appearance nil) (set apppearance "dark"))
  (vim.api.nvim_set_option_value "background" appearance {}))

(set vim.g.neovide_theme :auto)
