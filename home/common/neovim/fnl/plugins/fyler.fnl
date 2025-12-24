(local fyler (require :fyler))

(fyler.setup {:integrations {:icon :nvim_web_devicons}})

(vim.keymap.set :n :<C-n> #(fyler.toggle {:kind :float})
                {:desc "Fyler - toggle"})
