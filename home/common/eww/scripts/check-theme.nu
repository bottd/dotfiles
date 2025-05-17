#!/usr/bin/env -S nu --stdin

let theme_file = $"($env.HOME)/.config/hypr/current-theme.conf"

if ($theme_file | path exists) {
    let is_symlink = try { (ls -la $theme_file | get target | is-not-empty) } catch { false }
    if $is_symlink {
        let current = (ls -la $theme_file | get target.0)
        if ($current | str contains "latte") {
            print "light"
        } else {
            print "dark"
        }
    } else {
        print "dark"
    }
} else {
    print "dark"
}