#!/usr/bin/env -S nu --stdin

let light_start = 6
let light_end = 20
let current_hour = (date now | date format "%H" | into int)

let theme_file = $"($env.HOME)/.config/hypr/current-theme.conf"
let light_theme = $"($env.HOME)/.config/hypr/latte.conf"
let dark_theme = $"($env.HOME)/.config/hypr/mocha.conf"

let (desired_theme, target_theme, gtk_theme, color_scheme) = if $current_hour >= $light_start and $current_hour < $light_end {
    ("light", $light_theme, "Catppuccin-Latte-Blue", "prefer-light")
} else {
    ("dark", $dark_theme, "Catppuccin-Mocha-Blue", "prefer-dark")
}

if ($theme_file | path exists) {
    let is_symlink = try { (ls -la $theme_file | get target | is-not-empty) } catch { false }
    if $is_symlink {
        let current = (ls -la $theme_file | get target.0)
        if $current == $target_theme {
            exit 0
        }
    }
}

rm -rf $theme_file
ln -s $target_theme $theme_file

^gsettings set org.gnome.desktop.interface gtk-theme $gtk_theme
^gsettings set org.gnome.desktop.interface color-scheme $color_scheme

if (which kvantummanager | is-not-empty) {
    let kvantum_theme = if $desired_theme == "dark" { "Catppuccin-Mocha" } else { "Catppuccin-Latte" }
    ^kvantummanager --set $kvantum_theme
}

let scheme_uint = if $desired_theme == "dark" { 1 } else { 2 }
^dbus-send --session --dest=org.freedesktop.portal.Desktop `
    --object-path=/org/freedesktop/portal/desktop `
    --method=org.freedesktop.portal.Settings.SettingChanged `
    "org.freedesktop.appearance" "color-scheme" $"<uint32 ($scheme_uint)>"

$env.GTK_THEME = $gtk_theme

^hyprctl reload

if (which waybar | is-not-empty) {
    try { ps | where name == "waybar" | get pid | each { |pid| kill -9 $pid } }
    spawn waybar
}

print $desired_theme