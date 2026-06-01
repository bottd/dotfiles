{ pkgs, ... }:
let
  configDir = ./config;
in
{
  xdg.configFile = {
    "awesome/rc.lua".source = "${configDir}/rc.lua";
    "awesome/init.fnl".source = "${configDir}/init.fnl";
    "awesome/keybinds.fnl".source = "${configDir}/keybinds.fnl";
    "awesome/rules.fnl".source = "${configDir}/rules.fnl";
    "awesome/widgets.fnl".source = "${configDir}/widgets.fnl";
    "awesome/theme.fnl".source = "${configDir}/theme.fnl";
  };

  home.packages = with pkgs; [
    luaPackages.fennel
    rofi
    picom
    feh
    maim
    xclip
  ];

  services.picom = {
    enable = true;
    fade = true;
    fadeDelta = 5;
    shadow = true;
    shadowOffsets = [ (-7) (-7) ];
    settings = {
      shadow-radius = 7;
      frame-opacity = 0.9;
    };
  };
}
