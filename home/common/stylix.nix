{ lib, pkgs, ... }:
{
  stylix = {
    cursor = {
      name = lib.mkDefault "Bibata-Modern-Classic";
      package = lib.mkDefault pkgs.bibata-cursors;
      size = lib.mkDefault 24;
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
