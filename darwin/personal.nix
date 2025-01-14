{inputs, home-manager, mac-app-util, ...}: {
  home-manager.lib.homeManagerConfiguration {
    pkgs = import nixpkgs {
      inherit system;
    };
    extraSpecialArgs = {
      username = "drakebott";
      root = ./../;
      neorgWorkspace = "chalet";
    };
    modules = [
      mac-app-util.homeManagerModules.default
      ../util/default.nix
      ../home.nix
      ../packages/darwin/default.nix
      ../packages/common/default.nix
    ];
  };
}
