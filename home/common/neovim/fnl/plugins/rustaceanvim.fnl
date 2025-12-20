(local blink (require :blink.cmp))

(set vim.g.rustaceanvim
     {:server {:default_settings {:rust-analyzer {:check {:command :clippy}}}
               :capabilities (blink.get_lsp_capabilities)}})
