{inputs, home-manager, nixpkgs, ...}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
      home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.drakebott = import ../../home.nix;

        home-manager.extraSpecialArgs = {
          username = "drakebott";
          root = ./../..;
          neorgWorkspace = "chalet";
        };
      }
    ../../util/default.nix
    ../../packages/darwin/default.nix
    ../../packages/common/default.nix
  ];
}
