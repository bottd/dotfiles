{ pkgs, lib, baseFontSize, ... }:
{
  wayland.windowManager.sway = {
    config = {
      fonts = {
        names = lib.mkForce [ "MonoLisa Nerd Font" ];
        size = lib.mkForce (baseFontSize * 1.0);
      };

      keybindings =
        let
          mod = "Mod4";
        in
        lib.mkOptionDefault {
          "${mod}+n" = "exec ghostty -e nvim";
          "${mod}+b" = "exec foliate";
        };

      startup = [
        { command = "ghostty"; }
      ];

      output = {
        "*" = {
          bg = "#ffffff solid_color";
        };
      };
    };

    extraConfig = ''
      seat * hide_cursor 3000
      for_window [class=".*"] opacity 1
      for_window [app_id=".*"] opacity 1
    '';
  };

  programs.fuzzel = {
    settings = {
      main = {
        font = lib.mkForce "MonoLisa Nerd Font:size=${toString (baseFontSize + 2)}";
        lines = 10;
        width = 40;
        horizontal-pad = 20;
        vertical-pad = 10;
      };
      border = {
        width = 2;
      };
    };
  };

  home.packages = with pkgs; [
    foliate
    zathura
  ];
}
