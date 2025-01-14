{inputs, home-manager, nixpkgs, ...}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.drakeb = {...}: {
          imports = [
            ../../home.nix
            ../../util/default.nix
            ../../packages/linux/default.nix
            ../../packages/common/default.nix
          ];
        };

        home-manager.extraSpecialArgs = {
          username = "drakeb";
          root = ./../..;
          neorgWorkspace = "chalet";
        };
      }
  ];
}
