(local conform (require :conform))
(local util (require :conform.util))

(conform.setup {:format_on_save {:timeout_ms 500 :lsp_format :fallback}
                :formatters_by_ft {:* [:treefmt]
                                   :lua [:stylua]
                                   :rust [:rustfmt]
                                   :toml [:taplo]
                                   :fennel [:fnlfmt]
                                   :clojure [:cljfmt]
                                   :janet [:janet-format]
                                   :css [:prettierd]
                                   :html [:prettierd]
                                   :json [:prettierd]
                                   :svelte [:prettierd]
                                   :javascript [:prettierd]
                                   :typescript [:prettierd]
                                   :typescriptreact [:prettierd]}
                :formatters {:treefmt {:command :treefmt
                                       :stdin true
                                       :args [:--stdin :$FILENAME]
                                       :cwd (util.root_file [:flake.nix])
                                       :condition (fn [self ctx]
                                                    (?. (vim.fs.find [:flake.nix]
                                                                     {:path ctx.filename
                                                                      :upward true})
                                                        1))}}})
