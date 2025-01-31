{pkgs, ...}: {
  nixpkgs.config.allowUnfree = true; # Allow unfree licensed packages, like spotify
  home.packages = with pkgs; [
    spotify
  ];
}
