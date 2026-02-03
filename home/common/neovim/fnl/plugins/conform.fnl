(local conform (require :conform))
(local util (require :conform.util))

(conform.setup {:format_on_save {:timeout_ms 500 :lsp_fallback true}
                :formatters_by_ft {:* [:treefmt]
                                   :lua [:stylua]
                                   :rust [:rustfmt]
                                   :toml [:taplo]
                                   :fennel [:fnlfmt]
                                   :clojure [:cljfmt]
                                   :babashka [:cljfmt]
                                   :css [:prettierd :prettier]
                                   :html [:prettierd :prettier]
                                   :json [:prettierd :prettier]
                                   :svelte [:prettierd :prettier]
                                   :javascript [:prettierd :prettier]
                                   :typescript [:prettierd :prettier]
                                   :typescriptreact [:prettierd :prettier]}
                :formatters {:treefmt {:command :treefmt
                                       :stdin true
                                       :args [:--stdin :$FILENAME]
                                       :cwd (util.root_file [:flake.nix])
                                       :condition (fn [self ctx]
                                                    (?. (vim.fs.find [:flake.nix]
                                                                     {:path ctx.filename
                                                                      :upward true})
                                                        1))}}})
