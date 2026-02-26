_: {
  home.file.".config/rift/config.toml".text = ''
    [settings]
    animate = true
    animation_duration = 0.3
    animation_fps = 100.0
    animation_easing = "ease_in_out"

    focus_follows_mouse = false
    mouse_follows_focus = true
    mouse_hides_on_focus = false

    hot_reload = true
    auto_focus_blacklist = []
    run_on_start = []

    [settings.layout]
    mode = "scrolling"

    [settings.layout.scrolling]
    animate = true
    column_width_ratio = 0.7
    min_column_width_ratio = 0.3
    max_column_width_ratio = 0.9
    alignment = "center"
    focus_navigation_style = "niri"

    [settings.layout.scrolling.gestures]
    enabled = true

    [settings.layout.stack]
    stack_offset = 0.0
    default_orientation = "perpendicular"

    [settings.layout.gaps.outer]
    top = 16
    left = 16
    bottom = 16
    right = 16

    [settings.layout.gaps.inner]
    horizontal = 16
    vertical = 16

    [settings.ui.menu_bar]
    enabled = true
    show_empty = false
    mode = "all"
    active_label = "index"
    display_style = "layout"

    [settings.ui.stack_line]
    enabled = false
    horiz_placement = "top"
    vert_placement = "left"
    thickness = 0.0
    spacing = 0.0

    [settings.ui.mission_control]
    enabled = false
    fade_enabled = false
    fade_duration_ms = 180.0

    [settings.gestures]
    enabled = true
    invert_horizontal_swipe = false
    skip_empty = true
    fingers = 3
    haptics_enabled = true
    haptic_pattern = "level_change"

    [settings.window_snapping]
    drag_swap_fraction = 0.3

    [virtual_workspaces]
    enabled = true
    default_workspace_count = 9
    auto_assign_windows = true
    preserve_focus_per_workspace = true
    workspace_auto_back_and_forth = true
    workspace_names = []
    app_rules = []
    workspace_rules = []

    [modifier_combinations]
    comb1 = "Alt + Shift"

    [keys]
    # Toggle rift on/off
    "Alt + Z" = "toggle_space_activated"

    # Focus (vim-style)
    "Alt + H" = { move_focus = "left" }
    "Alt + J" = { move_focus = "down" }
    "Alt + K" = { move_focus = "up" }
    "Alt + L" = { move_focus = "right" }

    # Move windows (vim-style)
    "comb1 + H" = { move_node = "left" }
    "comb1 + J" = { move_node = "down" }
    "comb1 + K" = { move_node = "up" }
    "comb1 + L" = { move_node = "right" }

    # Workspaces
    "Alt + 1" = { switch_to_workspace = 0 }
    "Alt + 2" = { switch_to_workspace = 1 }
    "Alt + 3" = { switch_to_workspace = 2 }
    "Alt + 4" = { switch_to_workspace = 3 }
    "Alt + 5" = { switch_to_workspace = 4 }
    "Alt + 6" = { switch_to_workspace = 5 }
    "Alt + 7" = { switch_to_workspace = 6 }
    "Alt + 8" = { switch_to_workspace = 7 }
    "Alt + 9" = { switch_to_workspace = 8 }

    # Move window to workspace
    "comb1 + 1" = { move_window_to_workspace = 0 }
    "comb1 + 2" = { move_window_to_workspace = 1 }
    "comb1 + 3" = { move_window_to_workspace = 2 }
    "comb1 + 4" = { move_window_to_workspace = 3 }
    "comb1 + 5" = { move_window_to_workspace = 4 }
    "comb1 + 6" = { move_window_to_workspace = 5 }
    "comb1 + 7" = { move_window_to_workspace = 6 }
    "comb1 + 8" = { move_window_to_workspace = 7 }
    "comb1 + 9" = { move_window_to_workspace = 8 }

    # Workspace navigation
    "Alt + Tab" = "switch_to_last_workspace"

    # Stacking
    "comb1 + Left" = { join_window = "left" }
    "comb1 + Right" = { join_window = "right" }
    "comb1 + Up" = { join_window = "up" }
    "comb1 + Down" = { join_window = "down" }
    "Alt + Comma" = "toggle_stack"
    "Alt + Slash" = "toggle_orientation"
    "Alt + Ctrl + E" = "unjoin_windows"

    # Window state
    "comb1 + Space" = "toggle_window_floating"
    "Alt + F" = "toggle_fullscreen"
    "comb1 + F" = "toggle_fullscreen_within_gaps"

    # Resize
    "comb1 + Equal" = "resize_window_grow"
    "comb1 + Minus" = "resize_window_shrink"

    # Launch terminal
    "Alt + Enter" = { exec = "open -na ghostty" }

    # Service
    "Alt + Ctrl + Q" = "save_and_exit"
  '';
}
