{ lib, ... }:
{
  imports = [
    ./awesome.nix
    ./picom.nix
    ./launcher.nix
    ./desktop.nix
    ./notifications.nix
    ./sandbox.nix
    ./prism.nix
  ];

  # atuin panics on first launch in a fresh home (settings.rs:617)
  programs.atuin.enable = lib.mkForce false;
}
