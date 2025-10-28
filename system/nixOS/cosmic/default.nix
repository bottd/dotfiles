{ pkgs, username, ... }:
{
  services = {
    displayManager.cosmic-greeter.enable = true;
    desktopManager.cosmic.enable = true;
  };

  services.displayManager.autoLogin = {
    enable = true;
    # Replace `yourUserName` with the actual username of user who should be automatically logged in
    user = username;
  };

  environment.systemPackages = with pkgs; [
    # Additional Wayland utilities
    wl-clipboard
    xwayland
  ];
}
