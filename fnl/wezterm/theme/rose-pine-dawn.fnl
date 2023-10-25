;; rose-pine-dawn
;; Copyright (c) 2022 rose-pine
;; Translated from lua to fennel by Drake Bott
;; repository: https://github.com/neapsix/wezterm
;; license: MIT
(local M {})
(local palette {
    :base "#faf4ed"
    :overlay "#f2e9e1"
    :muted "#9893a5"
    :text "#575279"
    :love "#b4637a"
    :gold "#ea9d34"
    :rose "#d7827e"
    :pine "#286983"
    :foam "#56949f"
    :iris "#907aa9"
    ;;highlight_high "#cecacd"
})

(local active_tab {
    :bg_color palette.overlay
    :fg_color palette.text
})

(local inactive_tab {
    :bg_color palette.base
    :fg_color palette.muted
})

(fn M.colors []
    {
        :foreground palette.text
        :background palette.base
        :cursor_bg palette.muted
        :cursor_border palette.muted
        :cursor_fg palette.text
        :selection_bg palette.overlay
        :selection_fg palette.text
        :ansi [
            "#f2e9de"
            palette.love
            palette.pine
            palette.gold
            palette.foam
            palette.iris
            palette.rose
            palette.text
        ]
        :brights [
            ;; muted from rose-pine palette
            "#6e6a86" 
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
            :active_tab active_tab
            :inactive_tab inactive_tab
            :inactive_tab_hover active_tab
            :new_tab inactive_tab
            :new_tab_hover active_tab
            ;; (Fancy tab bar only)
            :inactive_tab_edge palette.muted 
        }
    })

;; (Fancy tab bar only)
(fn M.window_frame [] 
    {
        :active_titlebar_bg palette.base
        :inactive_titlebar_bg palette.base
})
M
