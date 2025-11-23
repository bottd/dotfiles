(local fyler (require :fyler))

(fyler.setup {:integrations {:icon :mini_icons}})

(vim.keymap.set :n :<C-n> #(fyler.toggle {:kind :float})
                {:desc "Fyler - toggle"})
