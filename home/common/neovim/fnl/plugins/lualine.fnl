(local lualine (require :lualine))

(lualine.setup {:options {:theme :catppuccin
                          :icons_enabled true
                          :globalstatus true
                          :component_separators "|"
                          :section_separators {:left "" :right ""}
                          :disabled_filetypes {}}
                :sections {:lualine_a [:mode]
                           :lualine_b [:branch :diff :diagnostics]
                           :lualine_c [:lsp_progress]
                           :lualine_x [:encoding :filetype]
                           :lualine_y [:progress]
                           :lualine_z [:location]}
                :winbar {:lualine_a [:filename]}
                :inactive_winbar {:lualine_a [:filename]}
                :tabline {}
                :extensions {}})
