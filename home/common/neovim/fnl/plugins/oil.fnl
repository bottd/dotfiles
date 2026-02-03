(local oil (require :oil))

(oil.setup {:float {:padding 17}})

(vim.keymap.set :n :<C-n> oil.toggle_float {:desc "Oil - parent directory"})

(vim.keymap.set :n :<C-m> #(-> (vim.api.nvim_buf_get_name 0)
                               (string.gsub "/[^/]+$" "")
                               (oil.toggle_float))
                {:desc "Oil - current directory"})
