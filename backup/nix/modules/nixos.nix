# NixOS configurations module for flake-parts
{
  inputs,
  self,
  ...
}: {
  flake = {
    nixosConfigurations = {
      desktop = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          username = "drakeb";
          host = "desktop";
          paths = {
            root = self;
            system = self + "/system";
            systemModules = self + "/system/modules";
            home = self + "/home";
            homeCommon = self + "/home/common";
            homeDarwin = self + "/home/darwin";
            homeLinux = self + "/home/linux";
          };
        };
        modules = [
          # System configuration
          (self + "/system/hosts/desktop")

          # Home manager module
          inputs.home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                username = "drakeb";
                paths = {
                  root = self;
                  system = self + "/system";
                  systemModules = self + "/system/modules";
                  home = self + "/home";
                  homeCommon = self + "/home/common";
                  homeDarwin = self + "/home/darwin";
                  homeLinux = self + "/home/linux";
                };
                root = self;
                neorgWorkspace = "chalet";
              };
              users.drakeb = {
                imports = [
                  # Home configuration
                  (self + "/home.nix")

                  # Utility functions
                  (self + "/util/createSymlink.nix")

                  # Platform and feature-specific modules
                  (self + "/home/linux")
                  (self + "/home/linux/hyprland/host/desktop.nix")
                  (self + "/home/common")
                ];
              };
            };
          }
        ];
      };
    };
  };
}
