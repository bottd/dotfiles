(local nvim-autopairs (require :nvim-autopairs))
(nvim-autopairs.setup)
(local {: setup} (require :care))
; TODO: 
; - prioirty config
; - disable cmp_cmdline in .fnl
; - colors and icons
; - mappings for docs view
(setup {:ui {:ghost_text {:position :inline}
             :menu {:max_height 10
                    :format_entry (fn [entry data]
                                    (local labels [:q :w :r :t :z :i])
                                    (local components
                                           (require :care.presets.components))
                                    (local preset_utils
                                           (require :care.presets.utils))
                                    [(components.ShortcutLabel labels entry
                                                               data)
                                     (components.Label entry data true)
                                     (components.KindIcon entry :blended)
                                     [[(.. " (" data.source_name ") ")
                                       (preset_utils.kind_highlight entry :fg)]]])}}
        :alignment [:left :right]
        :selection_behavior :insert
        :confirm_behavior :replace
        :sorting_direction :away-from-cursor
        :sources {:lsp {:max_entries 5 :priority 1}
                  :cmp_buffer {:max_entries 3}}
        :snippet_expansion (fn [body]
                             (local {: lsp_expand} (require :luasnip))
                             (lsp_expand body))})

(vim.keymap.set :i :<Cr> "<Plug>(CareConfirm)")
(vim.keymap.set :i :<c-e> "<Plug>(CareClose)")
(vim.keymap.set :i :<c-n> "<Plug>(CareSelectNext)")
(vim.keymap.set :i :<c-p> "<Plug>(CareSelectPrev)")
