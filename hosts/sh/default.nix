{
  lib,
  pkgs,
  theme,
  ...
}:
let
  scheme = import ../../lib/stylixScheme.nix {
    inherit pkgs;
    inherit (theme) appearance scheme;
  };
in
{
  imports = [ ../../home/common ];

  fonts.fontconfig.enable = lib.mkForce false;
  stylix = {
    enable = true;
    inherit (scheme) base16Scheme polarity;
    image = null;
    autoEnable = false;
    targets = {
      bat.enable = true;
      zellij.enable = true;
    };
  };

  # Standalone users may still log in with bash; NixOS integration selects zsh.
  programs.bash.enable = true;
  home.packages = with pkgs; [
    fnlfmt
    lua-language-server
    lua5_1
    lua51Packages.luarocks
    nixfmt
    stylua
  ];
}
