(local fyler (require :fyler))

(fyler.setup)

(vim.keymap.set :n :<C-n> #(fyler.toggle {:kind :float})
                {:desc "Fyler - toggle"})
