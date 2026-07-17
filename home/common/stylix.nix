{ lib, theme, pkgs, ... }:
let
  inherit (import ../../lib/stylixScheme.nix { inherit pkgs; inherit (theme) appearance scheme; }) base16Scheme polarity;
in
{
  stylix = {
    enable = lib.mkDefault true;
    base16Scheme = lib.mkDefault base16Scheme;
    polarity = lib.mkDefault polarity;
    autoEnable = lib.mkDefault true;
    image = lib.mkDefault null;

    # Themed cursor. niri-flake's stylix target reads this to set niri's xcursor
    # theme + size; also themes GTK/other apps' cursors. (Global, not niri-only.)
    cursor = {
      name = lib.mkDefault "Bibata-Modern-Classic";
      package = lib.mkDefault pkgs.bibata-cursors;
      size = lib.mkDefault 24;
    };

    fonts = {
      monospace = {
        name = lib.mkOptionDefault "MonoLisa Nerd Font";
        # MonoLisa is a commercial font installed outside Nix
        package = lib.mkOptionDefault pkgs.emptyDirectory;
      };
      sizes.terminal = lib.mkOptionDefault theme.baseFontSize;
    };

    targets = {
      # disable to prevent conflicts with kde
      gtk.enable = false;
    };
  };

  fonts.fontconfig.configFile.monolisa-nerd-font = lib.mkIf pkgs.stdenv.isLinux {
    enable = true;
    priority = 60;
    text = ''
      <?xml version="1.0"?>
      <!DOCTYPE fontconfig SYSTEM "fonts.dtd">
      <fontconfig>
        <match target="pattern">
          <test name="family" compare="eq" qual="any">
            <string>MonoLisa Nerd Font</string>
          </test>
          <edit name="family" mode="prepend" binding="strong">
            <string>MonoLisa Variable</string>
            <string>Symbols Nerd Font Mono</string>
          </edit>
        </match>
      </fontconfig>
    '';
  };

}
