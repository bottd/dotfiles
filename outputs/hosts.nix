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
        extraModules = [
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

      pocket = mkSystem {
        hostName = "pocket";
        system = "x86_64-linux";
        username = "drakeb";
        format = "nixos";
        extraModules = [
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

    darwinConfigurations = {
      macbook = mkSystem {
        hostName = "macbook";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "darwin";
        extraModules = [
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
      iris = mkHome {
        hostName = "iris";
        system = "aarch64-darwin";
        username = "drakebott";
        format = "home-manager";
      };
    };
  };
}
