{ lib
, pkgs
, username
, ...
}:
{
  imports = [ ];

  home.username = username;

  #WARNING: Don't change this without reading docs
  home.stateVersion = "25.05";
  # Let home manager manage itself
  programs.home-manager.enable = true;

  home.homeDirectory = "/Users/${username}";

  xdg.enable = true;
  nix = {
    # Configure the Nix package manager itself
    package = lib.mkForce pkgs.nix;
    settings.experimental-features = [ "nix-command" "flakes" ];
  };
}
