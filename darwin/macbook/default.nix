{home-manager, mac-app-util, nix-darwin, nixpkgs, ...}:
  nix-darwin.lib.darwinSystem {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    system = "aarch64-darwin";
    modules = [
      mac-app-util.darwinModules.default
      ../util/default.nix
      ./configuration.nix
      home-manager.darwinModules.home-manager {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.drakebott.imports = [
          mac-app-util.homeManagerModules.default
          ../../home.nix
          ../../home/darwin/default.nix
          ../../home/common/default.nix
        ];
        extraSpecialArgs = {
          username = "drakebott";
          root = ./../..;
          neorgWorkspace = "chalet";
        };
      }
    ];
  }
