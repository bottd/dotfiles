[
  {
    1 :rose-pine/neovim
    :name "rose-pine"
    :lazy false
    :priority 1000
    :config (fn [] 
      ((. (require :rose-pine) :setup) { :dark_variant "moon" }))
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
  {
    1 :f-person/auto-dark-mode.nvim
    :config {
      :update_interval 1000
      :set_dark_mode (fn []
        (vim.api.nvim_set_option "background" "dark")
        (vim.cmd "colorscheme rose-pine"))
      :set_light_mode (fn []
       (vim.api.nvim_set_option "background" "light")
       (vim.cmd "colorscheme rose-pine"))
    }
  }
]
