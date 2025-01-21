{home-manager, nixpkgs, ...}:
nixpkgs.lib.nixosSystem {
  system = "x86_64-linux";
  modules = [
    ./configuration.nix
    ../modules
    home-manager.nixosModules.home-manager
      {
        home-manager.useGlobalPkgs = true;
        home-manager.useUserPackages = true;
        home-manager.users.drakeb = {...}: {
          imports = [
            ../../home.nix
            ../../util/default.nix
            ../../home/linux/default.nix
            ../../home/common/default.nix
            ../../home/gaming.nix
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
