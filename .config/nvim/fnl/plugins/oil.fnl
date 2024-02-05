{
  1 :stevearc/oil.nvim
  :dependencies [:nvim-tree/nvim-web-devicons]
  :config (fn []
    (let [oil (require :oil)]
      (oil.setup {
        :float {
          :padding 17
        }
      })
    )
  )
  :keys [
    {
      :mode "n"
      1 "<C-n>"
      2 (fn []
          (let [oil (require :oil)]
            (oil.toggle_float)
          )
        )
      :desc "Oil - parent directory"
    }
    {
      :mode "n"
      1 "<C-m>"
      2 (fn []
        (let [buf_name (vim.api.nvim_buf_get_name 0)]
          (let [current_dir (string.gsub buf_name "/[^/]+$" "")]
            (let [oil (require :oil)]
              (oil.toggle_float current_dir)
            )
          )
        ))
      :desc "Oil - current directory"
    }

  ]
}
