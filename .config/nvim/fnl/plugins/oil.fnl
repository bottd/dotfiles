(let [oil (require :oil)]
  (oil.setup {:float {:padding 17}})
  (vim.keymap.set :n :<C-n>
                  (fn []
                    (let [oil (require :oil)]
                      (oil.toggle_float)))
                  {:desc "Oil - parent directory"})
  (vim.keymap.set :n :<C-m>
                  (fn []
                    (let [buf_name (vim.api.nvim_buf_get_name 0)]
                      (let [current_dir (string.gsub buf_name "/[^/]+$" "")]
                        (let [oil (require :oil)]
                          (oil.toggle_float current_dir)))))
                  {:desc "Oil - current directory"}))

;(vim.keymap.set
;  :n
;  "<C-v>"
;  (fn []
;    (let [oil (require :oil)]
;      (oil.select { :vertical true })))
;  { :desc "Oil - select vsplit" :buffer "oil" }))

