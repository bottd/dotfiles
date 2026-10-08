{
  features,
  lib,
  pkgs,
  ...
}:
{
  imports = [
    ./ai
    ./bitwarden.nix
    ./emacs.nix
    ./language.nix
    ./neovim
    ./scripts.nix
    ../common/browser.nix
    ../common/ghostty.nix
    ../common/glide
  ]
  ++ lib.optionals features.gaming [ ../common/games ];

  home.packages = with pkgs; [
    android-tools
    ffmpeg
    nh
    notmuch
    typst
  ];
}
