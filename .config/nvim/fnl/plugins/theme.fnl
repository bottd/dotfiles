{
  1 {
    1 :rose-pine/neovim
    :name "rose-pine"
    :lazy false
    :priority 1000
    :dependencies [:f-person/auto-dark-mode.nvim]
    :config (fn []
      (let [rose-pine (require :rose-pine)]
      (rose-pine.setup { :dark_variant "moon" }))
      (let [auto-dark-mode (require :auto-dark-mode)]
        (auto-dark-mode.setup {
          :update_interval 1000
          :set_dark_mode (fn []
           (vim.api.nvim_set_option "background" "dark")
           (vim.cmd "colorscheme rose-pine")
          )
          :set_light_mode (fn []
           (vim.api.nvim_set_option "background" "light")
           (vim.cmd "colorscheme rose-pine")
          )
        })
        (auto-dark-mode.init)
      )
    )
  }
  2 {
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
}
