(local fyler (require :fyler))

(fyler.setup {:win {:kind :float}})

(vim.keymap.set :n :<C-n> #(fyler.toggle) {:desc "Fyler - toggle"})
