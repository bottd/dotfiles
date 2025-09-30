(local fyler (require :fyler))

(fyler.setup {:win {:kind :float}})

(vim.keymap.set :n :<C-n> #(fyler.open) {:desc "Fyler - toggle"})
