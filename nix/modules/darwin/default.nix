# Module for Darwin configurations
{
  inputs,
  self,
  ...
}: {
  # Darwin configurations shared between all flake-parts modules
  flake = {
    darwinConfigurations = {
      macbook = inputs.nix-darwin.lib.darwinSystem {
        system = "aarch64-darwin";
        specialArgs = {
          inherit inputs;
          username = "drakebott";
          host = "macbook";
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
          "${self}/system/hosts/macbook"
          inputs.home-manager.darwinModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs;
                username = "drakebott";
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
              users.drakebott = {
                imports = [
                  "${self}/home.nix"
                  "${self}/util/createSymlink.nix"
                  "${self}/home/darwin"
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
