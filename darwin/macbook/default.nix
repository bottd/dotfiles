{home-manager, mac-app-util, nix-darwin, nixpkgs, ...}:
  nix-darwin.lib.darwinSystem {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    system = "aarch64-darwin";
    modules = [
      mac-app-util.darwinModules.default
        ./configuration.nix
        home-manager.darwinModules.home-manager {
          users.users.drakebott.home = "/Users/drakebott";
          home-manager = {
            useGlobalPkgs = true;
            useUserPackages = true;
            extraSpecialArgs = {
              username = "drakebott";
              root = ./../..;
              neorgWorkspace = "chalet";
            };
            users.drakebott = {
              imports = [
                mac-app-util.homeManagerModules.default
                  ../../util/default.nix
                  ../../home.nix
                  ../../home/darwin/default.nix
                  ../../home/common/default.nix
              ];
            };
          };
        }
    ];
  }
