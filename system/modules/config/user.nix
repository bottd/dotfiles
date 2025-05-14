# User configuration module that uses the config system
{
  config,
  lib,
  pkgs,
  ...
}: let
  # Import the module system
  moduleSystem = import ../utils/module-system.nix {inherit lib;};

  # Get the module configuration
  cfg = moduleSystem.getModuleConfig config.sysConfig.user;
in {
  config = {
    # Create the user
    users.users.${cfg.name} = {
      isNormalUser = true;
      description = cfg.fullName;
      extraGroups = cfg.extraGroups;
      shell = cfg.shell;

      # Ensure the user has a home directory and basic permissions
      home =
        if pkgs.stdenv.hostPlatform.isLinux
        then "/home/${cfg.name}"
        else "/Users/${cfg.name}";
    };

    # Set options for shells
    programs.zsh.enable = cfg.shell == pkgs.zsh;
    programs.fish.enable = cfg.shell == pkgs.fish;
    programs.bash.enable = true; # Always enable bash as a fallback

    # Basic user utilities
    environment.systemPackages = with pkgs; [
      man-pages
      man-pages-posix
    ];

    # Configure sudo for the user
    security.sudo = {
      enable = true;
      extraRules = [
        {
          groups = ["wheel"];
          commands = [
            {
              command = "ALL";
              options = ["NOPASSWD"];
            }
          ];
        }
      ];
    };
  };
}
