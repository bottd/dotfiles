{home-manager, mac-app-util, nixpkgs, ...}:
  home-manager.lib.homeManagerConfiguration {
    pkgs = nixpkgs.legacyPackages.aarch64-darwin;
    extraSpecialArgs = {
      username = "drakebott";
      root = ./..;
      neorgWorkspace = "chalet";
    };
    modules = [
      mac-app-util.homeManagerModules.default
      ../util/default.nix
      ../home.nix
      ../home/darwin/default.nix
      ../home/common/default.nix
    ];
  }
