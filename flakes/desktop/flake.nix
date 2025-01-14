{
  description = "Drake - Desktop";
  inputs = {
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = { 
    self, 
    nixpkgs,
    home-manager, 
    ... 
  } @ inputs: let 
    inherit (self) outputs;
  in {
    nixosConfigurations = {
      nixos = nixpkgs.lib.nixosSystem {
        system = "x86_64-linux";
        specialArgs = {
          inherit inputs outputs;
        };
        modules = [
          ./configuration.nix
          ../../util/default.nix
          ../../packages/common/default.nix
          ../../packages/linux/default.nix
          home-manager.nixosModules.home-manager
          {
            home-manager.useGlobalPkgs = true;
            home-manager.useUserPackages = true;
            home-manager.users.drakeb = import ../../home.nix;
            home-manager.extraSpecialArgs = {
              username = "drakeb";
              root = ../../.;
              neorgWorkspace = "chalet";
            };
          }
        ];
      };
    };
  };
}
