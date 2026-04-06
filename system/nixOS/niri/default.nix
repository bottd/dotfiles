{ pkgs, inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  programs.niri = {
    enable = true;
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    wl-clipboard
    xwayland
  ];
}
