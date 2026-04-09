(local lualine (require :lualine))
(local lualine-themes {:tokyonight :tokyonight :solarized-light :solarized})

(local theme (or (. lualine-themes vim.g.stylix_theme) :base16))

(lualine.setup {:options {: theme
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
