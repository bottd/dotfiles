(let [lsp_zero (require :lsp-zero)
      cmp (require :cmp)
      cmp_action (lsp_zero.cmp_action)
      cmp_autopairs (require :nvim-autopairs.completion.cmp)]
  (lsp_zero.extend_cmp)
  (cmp.event:on :confirm_done (cmp_autopairs.on_confirm_done))
  (cmp.setup {:snippet {:expand (fn [args]
                                  (local {: lsp_expand} (require :luasnip))
                                  (lsp_expand args.body))}
              :formatting (lsp_zero.cmp_format)
              :mapping (cmp.mapping.preset.insert {:<C-Space> (cmp.mapping.complete)
                                                   :<C-u> (cmp.mapping.scroll_docs -4)
                                                   :<C-d> (cmp.mapping.scroll_docs 4)
                                                   :<C-f> (cmp_action.luasnip_jump_forward)
                                                   :<C-b> (cmp_action.luasnip_jump_backward)
                                                   ;; Accept currently selected item. Set `select` to `false` to only confirm explicitly selected items.
                                                   :<CR> (cmp.mapping.confirm {:select true})})
              :sources (cmp.config.sources [{:name :copilot}
                                            {:name :nvim_lsp}
                                            {:name :luasnip}
                                            {:name :conjure}
                                            {:name :path}
                                            {:name :buffer}
                                            ;; enable spell complete in md,norg, etc?
                                            ;; { :name "spell" }
                                            {:name :neorg}])}))

