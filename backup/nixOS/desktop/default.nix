{inputs, ...}: let
  inherit
    (inputs)
    home-manager
    nixpkgs
    ;
in
  nixpkgs.lib.nixosSystem {
    system = "x86_64-linux";
    modules = [
      # Basic system configuration
      ./configuration.nix

      # Original modules
      ../modules

      # New wrapper modules that mirror the system/modules content
      # These avoid path resolution issues while migrating to new structure
      ./base-settings.nix
      ./common-settings.nix
      ./user-settings.nix

      # Home manager module
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.drakeb = {...}: {
          imports = [
            ../../home.nix
            ../../util/default.nix
            ../../home/linux/default.nix
            ../../home/linux/hyprland/host/desktop.nix
            ../../home/common/default.nix
          ];
        };

        home-manager.extraSpecialArgs = {
          username = "drakeb";
          root = ./../..;
          neorgWorkspace = "chalet";
          inherit inputs;
        };
      }
    ];
    specialArgs = {
      inherit inputs;
      username = "drakeb";
      host = {
        system = "x86_64-linux";
        format = "nixos";
        username = "drakeb";
      };
    };
  }
