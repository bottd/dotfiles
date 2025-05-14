# Module for NixOS configurations
{
  inputs,
  self,
  ...
}: {
  # System configurations shared between all flake-parts modules
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
            system = "${self}/system";
            systemModules = "${self}/system/modules";
            home = "${self}/home";
            homeCommon = "${self}/home/common";
            homeDarwin = "${self}/home/darwin";
            homeLinux = "${self}/home/linux";
          };
        };
        modules = [
          "${self}/system/hosts/desktop"
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
                  system = "${self}/system";
                  systemModules = "${self}/system/modules";
                  home = "${self}/home";
                  homeCommon = "${self}/home/common";
                  homeDarwin = "${self}/home/darwin";
                  homeLinux = "${self}/home/linux";
                };
                root = self;
                neorgWorkspace = "chalet";
              };
              users.drakeb = {
                imports = [
                  "${self}/home.nix"
                  "${self}/util/createSymlink.nix"
                  "${self}/home/linux"
                  "${self}/home/linux/hyprland/host/desktop.nix"
                  "${self}/home/common"
                ];
              };
            };
          }
        ];
      };

      pocket = inputs.nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs;
          username = "drakeb";
          host = "pocket";
          paths = {
            root = self;
            system = "${self}/system";
            systemModules = "${self}/system/modules";
            home = "${self}/home";
            homeCommon = "${self}/home/common";
            homeDarwin = "${self}/home/darwin";
            homeLinux = "${self}/home/linux";
          };
        };
        modules = [
          "${self}/system/hosts/pocket"
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
                  system = "${self}/system";
                  systemModules = "${self}/system/modules";
                  home = "${self}/home";
                  homeCommon = "${self}/home/common";
                  homeDarwin = "${self}/home/darwin";
                  homeLinux = "${self}/home/linux";
                };
                root = self;
                neorgWorkspace = "chalet";
              };
              users.drakeb = {
                imports = [
                  "${self}/home.nix"
                  "${self}/util/createSymlink.nix"
                  "${self}/home/linux"
                  "${self}/home/linux/hyprland/host/pocket.nix"
                  "${self}/home/common"
                ];
              };
            };
          }
        ];
      };
    };
  };
}
