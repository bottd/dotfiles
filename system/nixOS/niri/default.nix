{ pkgs, inputs, ... }:
{
  imports = [
    inputs.niri.nixosModules.niri
  ];

  programs.niri = {
    enable = true;
  };

  services.displayManager.sddm = {
    enable = true;
    wayland.enable = true;
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    # Additional Wayland utilities
    wl-clipboard
    xwayland
  ];
}
