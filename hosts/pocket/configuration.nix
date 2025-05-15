{ pkgs
, ...
}: {
  imports = [
    ./hardware-configuration.nix
  ];

  # Bootloader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "";
  };

  environment.systemPackages = with pkgs; [
    grim
    slurp
    wl-clipboard
    mako
    helvum
    ghostty
  ];

  # Use this fixed version - do not change without reading docs
  system.stateVersion = "24.11";
}
