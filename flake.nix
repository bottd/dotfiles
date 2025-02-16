{
  description = "Drake Flake";
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = {
    home-manager,
    mac-app-util,
    nix-darwin,
    nixpkgs,
    ...
  } @ inputs: rec {
    # darwin-rebuild switch --flake .#iris
    darwinConfigurations = {
      macbook = import ./darwin/macbook {
        inherit inputs home-manager mac-app-util nix-darwin nixpkgs;
      };
    };
    # sudo nixos-rebuild switch --flake .#desktop
    nixosConfigurations = {
      desktop = import ./nixOS/desktop inputs;
    };
    # home-manager switch --flake .#iris
    homeConfigurations = {
      iris = import ./darwin/iris.nix {inherit inputs home-manager mac-app-util nixpkgs;};
    };
  };
}
