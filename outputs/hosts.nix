{ inputs
, ...
}:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;
in
{
  imports = [ ];

  flake = {
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
