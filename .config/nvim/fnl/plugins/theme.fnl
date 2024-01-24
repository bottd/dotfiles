[
  {
    1 :rose-pine/neovim
    :name "rose-pine"
    :lazy false
    :priority 1000
    :config (fn [] 
      ((. (require :rose-pine) :setup) { :dark_variant "moon" })
      (vim.cmd "colorscheme rose-pine")
      ;; window_appearance is set in wezterm config
      (let [appearance (os.getenv :WINDOW_APPEARANCE)]
        (when (= appearance nil) (set apppearance "dark"))
        (vim.api.nvim_set_option_value "background" appearance {})
      )
    )
  }
  {
    1 :lukas-reineke/indent-blankline.nvim
    :main "ibl"
    :config (fn []
      (let [ibl (require :ibl)]
        (ibl.setup {
          :indent { :char "│" }
          :scope { :enabled true }
      })))
      :opts {
        :space_char_blankline " "
        :show_current_context true
        :show_current_context_start true
      }
  }
]
