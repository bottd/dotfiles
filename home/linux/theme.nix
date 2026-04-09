{ lib, theme, ... }:
{
  dconf.settings."org/gnome/desktop/interface" = {
    color-scheme = lib.mkForce (if theme.appearance == "light" then "prefer-light" else "prefer-dark");
  };
}
