{ pkgs, ... }:
{
  services.desktopManager.plasma6.enable = true;

  environment.plasma6.excludePackages = with pkgs.kdePackages; [
    oxygen
  ];

  programs.dconf.enable = true;

  environment.systemPackages = with pkgs; [
    filezilla
    kdePackages.kdeconnect-kde
    kdePackages.kio-extras
    kdePackages.kdeplasma-addons
    kdePackages.kwalletmanager
    kdePackages.partitionmanager
    kdePackages.plasma-browser-integration
    kdePackages.plasma-disks
    kdePackages.plasma-nm
    kdePackages.plasma-pa
    kdePackages.plasma-thunderbolt
    kdePackages.powerdevil
    kdePackages.spectacle
  ];
}
