(local oil (require :oil))

(oil.setup {:float {:padding 17}})

(vim.keymap.set :n :<C-n> oil.toggle_float {:desc "Oil - parent directory"})

(vim.keymap.set :n :<C-m>
                (fn []
                  (let [buf-name (vim.api.nvim_buf_get_name 0)
                        current-dir (string.gsub buf-name "/[^/]+$" "")]
                    (oil.toggle_float current-dir)))
                {:desc "Oil - current directory"})
