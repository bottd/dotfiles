{inputs, ...}: let
  inherit
    (inputs)
    home-manager
    mac-app-util
    nix-darwin
    nixpkgs
    ;
in
  nix-darwin.lib.darwinSystem {
    pkgs = import nixpkgs {
      system = "aarch64-darwin";
      config.allowUnfree = true;
    };
    specialArgs = {
      inherit inputs;
    };
    system = "aarch64-darwin";
    modules = [
      mac-app-util.darwinModules.default
      ./configuration.nix
      home-manager.darwinModules.home-manager
      {
        users.users.drakebott.home = "/Users/drakebott";
        home-manager = {
          useGlobalPkgs = true;
          useUserPackages = true;
          extraSpecialArgs = {
            username = "drakebott";
            root = ./../..;
            neorgWorkspace = "chalet";
            inherit inputs;
          };
          users.drakebott = {...}: {
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
