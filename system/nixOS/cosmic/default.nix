{ pkgs, ... }:
{
  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
  };

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    # Additional Wayland utilities
    wl-clipboard
    xwayland
  ];
}
