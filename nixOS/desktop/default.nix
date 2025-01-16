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
<<<<<<< HEAD
            ../../home/linux/default.nix
            ../../home/common/default.nix
=======
            ../../packages/common/default.nix
>>>>>>> d8fab94 (Update)
            ../../packages/gaming.nix
          ];
        };

        home-manager.extraSpecialArgs = {
          username = "drakeb";
          root = ./../..;
          neorgWorkspace = "chalet";
        };
      }
  ../../packages/linux/default.nix
  ];
}
