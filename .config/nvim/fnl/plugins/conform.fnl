(let [conform (require :conform)]
  (conform.setup {:format_on_save {:timeout_ms 500 :lsp_fallback true}
                  :formatters_by_ft {:fennel [:fnlfmt]
                                     :javascript [:prettierd :prettier]
                                     :lua [:stylua]
                                     :rust [:rustfmt]
                                     :toml [:taplo]}}))

