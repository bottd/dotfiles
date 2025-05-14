# Security configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.security;

  # Helper to check if a feature is enabled
  isEnabled = feature: cfg.${feature} or false;
in {
  config = lib.mkMerge [
    # Basic security settings
    {
      security = {
        # Protect against brute-force login attempts
        pam.p11.enable = true;

        # Setup sudo with password
        sudo.enable = true;
        sudo.wheelNeedsPassword = true;

        # Security audit
        auditd.enable = true;

        # Hardening
        protectKernelImage = true;
      };

      # Basic security packages
      environment.systemPackages = with pkgs; [
        gnupg
        pinentry
        keepassxc
        openssl
      ];

      # Ensure that /tmp is cleaned on boot
      boot.tmp.cleanOnBoot = true;
    }

    # Firewall configuration
    (lib.mkIf (isEnabled "enableFirewall") {
      networking.firewall = {
        enable = true;
        allowPing = true;

        # Sensible defaults for firewall
        allowedTCPPorts = [22]; # SSH
        allowedUDPPorts = [];
      };
    })

    # SSH configuration
    (lib.mkIf (isEnabled "enableSSH") {
      services.openssh = {
        enable = true;
        settings = {
          PermitRootLogin = "no";
          PasswordAuthentication = false;
          X11Forwarding = false;
          KbdInteractiveAuthentication = false;
        };
      };

      # Add SSH packages
      environment.systemPackages = with pkgs; [
        openssh
      ];

      # Add SSH port to firewall
      networking.firewall.allowedTCPPorts = [22];
    })

    # YubiKey configuration
    (lib.mkIf (isEnabled "yubikey") {
      services.udev.packages = with pkgs; [yubikey-personalization];
      services.pcscd.enable = true;

      # Add YubiKey packages
      environment.systemPackages = with pkgs; [
        yubikey-personalization
        yubikey-personalization-gui
        yubikey-manager
        yubioath-desktop
      ];

      # Configure PAM for YubiKey
      security.pam.services = {
        login.u2fAuth = true;
        sudo.u2fAuth = true;
      };
    })

    # GnuPG configuration
    (lib.mkIf (isEnabled "gnupg") {
      programs.gnupg.agent = {
        enable = true;
        enableSSHSupport = true;
      };

      # Add GnuPG packages
      environment.systemPackages = with pkgs; [
        gnupg
        pinentry-curses
        pinentry-gtk2
      ];
    })

    # Keyring configuration
    (lib.mkIf (isEnabled "keyring") {
      services.gnome.gnome-keyring.enable = true;
      security.pam.services.login.enableGnomeKeyring = true;

      # Add keyring packages
      environment.systemPackages = with pkgs; [
        gnome.gnome-keyring
        gnome.seahorse
      ];
    })
  ];
}
