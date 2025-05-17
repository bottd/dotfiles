#!/usr/bin/env -S nu --stdin

let theme_file = $"($env.HOME)/.config/hypr/current-theme.conf"
let light_theme = $"($env.HOME)/.config/hypr/latte.conf"
let dark_theme = $"($env.HOME)/.config/hypr/mocha.conf"

let (target_theme, desired_theme, gtk_theme, color_scheme) = if ($theme_file | path exists) {
    let is_symlink = try { (ls -la $theme_file | get target | is-not-empty) } catch { false }
    if $is_symlink {
        let current = (ls -la $theme_file | get target.0)
        if ($current | str contains "latte") {
            ($dark_theme, "dark", "Catppuccin-Mocha-Blue", "prefer-dark")
        } else {
            ($light_theme, "light", "Catppuccin-Latte-Blue", "prefer-light")
        }
    } else {
        ($dark_theme, "dark", "Catppuccin-Mocha-Blue", "prefer-dark")
    }
} else {
    ($dark_theme, "dark", "Catppuccin-Mocha-Blue", "prefer-dark")
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