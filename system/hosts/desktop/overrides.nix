# Override configuration for desktop host
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../../modules/utils/module-system.nix {inherit lib;};

  # Override functions
  overrideModule = moduleSystem.overrideModule;
in {
  # Override default user configuration
  sysConfig.user.overrides = {
    name = "drakeb";
    fullName = "Drake Bott";
    email = "drake@example.com";
    shell = pkgs.zsh;
    extraGroups = ["wheel" "networkmanager" "video" "audio" "docker"];
  };

  # Override default system configuration
  sysConfig.system.overrides = {
    timeZone = "America/Chicago";
    locale = "en_US.UTF-8";
    stateVersion = "24.11";
    autoUpgrade = false;
  };

  # Override default hardware configuration
  sysConfig.hardware.overrides = {
    cpuType = "amd";
    gpuType = "nvidia";
    bluetooth = true;
    printing = true;
    sound = true;
    opengl = true;
    virtualization = true;
  };

  # Override default desktop configuration
  sysConfig.desktop.overrides = {
    enable = true;
    useWayland = true;
    useX11 = false;
    useHyprland = true;
    useGnome = false;
    useKDE = false;
    theme = {
      name = "catppuccin-mocha";
      dark = true;
      accent = "blue";
    };
  };

  # Override default development configuration
  sysConfig.development.overrides = {
    enable = true;
    languages = {
      python = true;
      rust = true;
      go = true;
      node = true;
      java = false;
    };
    tools = {
      vscode = true;
      neovim = true;
      docker = true;
      git = true;
    };
  };

  # Override default security configuration
  sysConfig.security.overrides = {
    enableFirewall = true;
    enableSSH = true;
    yubikey = true;
    gnupg = true;
    keyring = true;
  };

  # Override default networking configuration
  sysConfig.networking.overrides = {
    wireless = false;
    networkManager = true;
    hostName = "nixos-desktop";
    firewall = {
      enable = true;
      allowPing = true;
    };
    tailscale = true;
  };

  # Override default storage configuration
  sysConfig.storage.overrides = {
    tmpOnTmpfs = true;
    zfs = false;
    optimizeNixStore = true;
    autoScrub = false;
  };

  # Override default applications configuration
  sysConfig.applications.overrides = {
    browsers = {
      firefox = true;
      chromium = false;
      brave = true;
    };
    terminals = {
      alacritty = false;
      kitty = false;
      wezterm = false;
      ghostty = true;
    };
    utilities = {
      fileManager = "dolphin";
      editor = "nvim";
      terminal = "ghostty";
      browser = "firefox";
    };
  };
}
