(local {: setup} (require :care))
; TODO: 
; - prioirty config
; - disable cmp_cmdline in .fnl
; - colors and icons
; - mappings for docs view
(setup {:ui {:ghost_text {:position :inline}
             :menu {:max_height 10
                    :format_entry (fn [entry data]
                                    (local {: get_kind_name}
                                           (require :care.utils.lsp))
                                    (local {: LabelEntries}
                                           (require :care.presets.utils))
                                    (local {: completion_item} entry)
                                    (local {: type_icons}
                                           (. (. (require :care.config)
                                                 :options)
                                              :ui))
                                    (local entry_kind
                                           (if (= (type completion_item.kind)
                                                  :string)
                                               completion_item.kind
                                               (get_kind_name completion_item.kind)))
                                    [[[completion_item.label]]
                                     [[(.. " "
                                           (or (. type_icons entry_kind)
                                               type_icons.Text)
                                           " ")
                                       (: "@care.type.%s" :format entry_kind)]
                                      [data.source_name]]])}}
        :alignment [:left :right]
        :selection_behavior :insert
        :confirm_behavior :insert
        :sorting_direction :away-from-cursor
        :sources {:lsp {:max_entries 5 :priority 99999}
                  :cmp_buffer {:max_entries 3 :priority 1}}
        :snippet_expansion (fn [body]
                             (local {: lsp_expand} (require :luasnip))
                             (lsp_expand body))})

(vim.keymap.set :i :<Cr> "<Plug>(CareConfirm)")
(vim.keymap.set :i :<c-e> "<Plug>(CareClose)")
(vim.keymap.set :i :<c-n> "<Plug>(CareSelectNext)")
(vim.keymap.set :i :<c-p> "<Plug>(CareSelectPrev)")
