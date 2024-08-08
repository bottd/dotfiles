(let [flash (require :flash)]
  (flash.setup {}))

(vim.keymap.set [:n :x :o] :s (fn []
                                (let [flash (require :flash)]
                                  (flash.jump)))
                {:desc :Flash})

(vim.keymap.set [:n :o :x] :S
                (fn []
                  (let [flash (require :flash)]
                    (flash.treesitter)))
                {:desc "Flash Treesitter"})

(vim.keymap.set :o :r (fn []
                        (let [flash (require :flash)]
                          (flash.remote)))
                {:desc "Remote Flash"})

(vim.keymap.set [:o :x] :R
                (fn []
                  (let [flash (require :flash)]
                    (flash.treesitter_search)))
                {:desc "Treesitter Search"})

(vim.keymap.set :c :<c-s> (fn []
                            (let [flash (require :flash)]
                              (flash.toggle)))
                {:desc "Toggle Flash Search"})

