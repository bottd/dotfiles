# Networking configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.networking;

  # Helper to check if a feature is enabled
  isEnabled = feature: cfg.${feature} or false;
in {
  config = lib.mkMerge [
    # Basic networking configuration
    {
      networking = {
        hostName = cfg.hostName;
        networkmanager.enable = isEnabled "networkManager";
        wireless.enable = isEnabled "wireless" && !isEnabled "networkManager";

        # Firewall configuration
        firewall = {
          enable = cfg.firewall.enable;
          allowPing = cfg.firewall.allowPing;
        };
      };

      # Common networking packages
      environment.systemPackages = with pkgs; [
        curl
        wget
        bind
        whois
        nmap
        iperf
        bandwhich
        inetutils
      ];

      # Make NetworkManager use the system DNS resolver
      networking.networkmanager.dns = "dnsmasq";
    }

    # Tailscale configuration
    (lib.mkIf (isEnabled "tailscale") {
      services.tailscale = {
        enable = true;
        openFirewall = true;
      };

      # Add tailscale packages
      environment.systemPackages = with pkgs; [
        tailscale
      ];

      # Configure firewall for tailscale
      networking.firewall = {
        trustedInterfaces = ["tailscale0"];
        allowedUDPPorts = [41641]; # Tailscale port
      };
    })

    # Wireless configuration
    (lib.mkIf (isEnabled "wireless") {
      # Add wireless tools
      environment.systemPackages = with pkgs; [
        wirelesstools
        iw
        wpa_supplicant_gui
      ];
    })

    # NetworkManager configuration
    (lib.mkIf (isEnabled "networkManager") {
      # Add NetworkManager tools
      environment.systemPackages = with pkgs; [
        networkmanagerapplet
        networkmanager-openvpn
        networkmanager-openconnect
      ];

      # Configure NetworkManager
      networking.networkmanager = {
        wifi.powersave = true;
        wifi.scanRandMacAddress = true;
        insertNameservers = ["1.1.1.1" "9.9.9.9"];
      };

      # Add user to networkmanager group
      users.users.${config.sysConfig.user.defaults.name}.extraGroups = ["networkmanager"];
    })
  ];
}
