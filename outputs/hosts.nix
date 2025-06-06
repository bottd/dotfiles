{ inputs
, ...
}:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;
in
{
  imports = [ ];

  flake = {
    nixosConfigurations = {
      desktop = mkSystem {
        hostName = "desktop";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        extraSystemModules = [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                neorgWorkspace = "chalet";
                root = ./.;
              };
            };
          }
        ];
        extraHomeModules = [
          ../home/linux/hyprland/host/desktop.nix
        ];
      };

      pocket = mkSystem {
        hostName = "pocket";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        extraSystemModules = [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                neorgWorkspace = "chalet";
                root = ./.;
              };
            };
          }
        ];
        extraHomeModules = [
          ../home/linux/hyprland/host/pocket.nix
        ];

      };
    };

    darwinConfigurations = {
      macbook = mkSystem {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        extraSystemModules = [
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                neorgWorkspace = "chalet";
                root = ./.;
              };
            };
          }
        ];
      };
    };

    homeConfigurations = {
      standalone = mkHome {
        hostName = "standalone";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "home-manager";
      };
    };
  };
}
