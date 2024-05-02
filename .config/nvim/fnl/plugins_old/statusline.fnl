{
  1 :nvim-lualine/lualine.nvim
  :dependencies {
    1 :nvim-tree/nvim-web-devicons
    2 :arkav/lualine-lsp-progress
    :lazy true
  }
  :config (fn []
    (let [lualine (require :lualine)]
      (lualine.setup {
        :options {
          :icons_enabled true
          :component_separators "|"
          :section_separators { :left "" :right "" }
          :globalstatus true
          :disabled_filetypes {}
        }
        :sections {
          :lualine_a [:mode]
          :lualine_b [:branch :diff :diagnostics]
          :lualine_c [:lsp_progress]
          :lualine_x [:encoding :filetype]
          :lualine_y [:progress]
          :lualine_z [:location]
        }
        :tabline {}
        :winbar {
          :lualine_a [:filename]
        }
        :inactive_winbar {
          :lualine_a [:filename]
        }
        :extensions {}
        })
    )
  )
}
