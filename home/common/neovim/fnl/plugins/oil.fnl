(local oil (require :oil))
(oil.setup {:float {:padding 17}})

(vim.keymap.set :n :<C-n> (oil.toggle_float) {:desc "Oil - parent directory"})

(vim.keymap.set :n :<C-m>
                (fn []
                  (local buf_name (vim.api.nvim_buf_get_name 0))
                  (local current_dir (string.gsub buf_name "/[^/]+$" ""))
                  (oil.toggle_float current_dir))
                {:desc "Oil - current directory"})
