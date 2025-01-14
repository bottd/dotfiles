{inputs, home-manager, mac-app-util, nixpkgs, ...}:
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    extraSpecialArgs = {
      username = "DBott";
      root = ../../.;
      neorgWorkspace = "notes";
    };
    modules = [
      mac-app-util.homeManagerModules.default
      ../util/default.nix
      ../home.nix
      ../packages/darwin/default.nix
      ../packages/common/default.nix
    ];
  }
