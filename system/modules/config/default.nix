# Centralized configuration module with defaults and overrides
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Helper to create a module option
  mkModuleOption = moduleSystem.mkModuleOption;

  # Helper to create a module
  mkModule = moduleSystem.mkModule;
in {
  # Define options for centralized configuration
  options.sysConfig = {
    # User configuration
    user = mkModuleOption "user" "User-specific configuration";

    # System configuration
    system = mkModuleOption "system" "System-wide configuration";

    # Hardware configuration
    hardware = mkModuleOption "hardware" "Hardware-specific configuration";

    # Desktop environment configuration
    desktop = mkModuleOption "desktop" "Desktop environment configuration";

    # Development environment configuration
    development = mkModuleOption "development" "Development environment configuration";

    # Security configuration
    security = mkModuleOption "security" "Security-related configuration";

    # Networking configuration
    networking = mkModuleOption "networking" "Networking configuration";

    # Storage configuration
    storage = mkModuleOption "storage" "Storage configuration";

    # Application configuration
    applications = mkModuleOption "applications" "Application-specific configuration";
  };

  # Set default values for all modules
  config.sysConfig = {
    # User defaults
    user = mkModule {
      defaults = {
        name = "drakeb";
        fullName = "Drake Bott";
        email = "drakeb@example.com";
        shell = pkgs.zsh;
        extraGroups = ["wheel" "networkmanager" "video"];
      };
    };

    # System defaults
    system = mkModule {
      defaults = {
        timeZone = "America/Chicago";
        locale = "en_US.UTF-8";
        stateVersion = "24.11";
        autoUpgrade = false;
      };
    };

    # Hardware defaults
    hardware = mkModule {
      defaults = {
        cpuType = "unknown"; # "intel", "amd", "arm"
        gpuType = "unknown"; # "nvidia", "amd", "intel", "apple"
        bluetooth = false;
        printing = false;
        sound = true;
        opengl = true;
        virtualization = false;
      };
    };

    # Desktop defaults
    desktop = mkModule {
      defaults = {
        enable = false;
        useWayland = false;
        useX11 = false;
        useHyprland = false;
        useGnome = false;
        useKDE = false;
        theme = {
          name = "catppuccin-mocha";
          dark = true;
          accent = "blue";
        };
      };
    };

    # Development defaults
    development = mkModule {
      defaults = {
        enable = false;
        languages = {
          python = false;
          rust = false;
          go = false;
          node = false;
          java = false;
        };
        tools = {
          vscode = false;
          neovim = true;
          docker = false;
          git = true;
        };
      };
    };

    # Security defaults
    security = mkModule {
      defaults = {
        enableFirewall = true;
        enableSSH = true;
        yubikey = false;
        gnupg = false;
        keyring = true;
      };
    };

    # Networking defaults
    networking = mkModule {
      defaults = {
        wireless = false;
        networkManager = true;
        hostName = "nixos";
        firewall = {
          enable = true;
          allowPing = true;
        };
        tailscale = false;
      };
    };

    # Storage defaults
    storage = mkModule {
      defaults = {
        tmpOnTmpfs = true;
        zfs = false;
        optimizeNixStore = true;
        autoScrub = false;
      };
    };

    # Applications defaults
    applications = mkModule {
      defaults = {
        browsers = {
          firefox = true;
          chromium = false;
          brave = false;
        };
        terminals = {
          alacritty = false;
          kitty = false;
          wezterm = false;
          ghostty = true;
        };
        utilities = {
          fileManager = "nautilus";
          editor = "nvim";
          terminal = "ghostty";
          browser = "firefox";
        };
      };
    };
  };
}
