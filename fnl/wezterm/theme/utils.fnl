(local utils {})
(fn utils.create_rose_pine_theme [palette] {
    :colors (fn [] {
      :foreground palette.text
      :background palette.base
      :cursor_bg palette.muted
      :cursor_border palette.muted
      :cursor_fg palette.text
      :selection_bg palette.overlay
      :selection_fg palette.text
      :ansi [
        palette.overlay
        palette.love
        palette.pine
        palette.gold
        palette.foam
        palette.iris
        palette.rose
        palette.text
      ]
      :brights [
        palette.muted
        palette.love
        palette.pine
        palette.gold
        palette.foam
        palette.iris
        palette.rose
        palette.text
      ]
      :tab_bar {
        :background palette.base
        :active_tab {
          :bg_color palette.overlay
          :fg_color palette.text
        }
        :inactive_tab {
          :bg_color palette.base
          :fg_color palette.muted
        }
        :inactive_tab_hover {
          :bg_color palette.overlay
          :fg_color palette.text
        }
        :new_tab {
          :bg_color palette.base
          :fg_color palette.muted
        }
        :new_tab_hover {
          :bg_color palette.overlay
          :fg_color palette.text
        }
        ;; (Fancy tab bar only)
        :inactive_tab_edge palette.muted 
    }})
    :window_frame (fn [] {
      :active_titlebar_bg palette.base
      :inactive_titlebar_bg palette.base
    })
  })
utils
