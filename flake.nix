{
  description = "Drake Flake";
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = {...} @ inputs: rec {
    # sudo nixos-rebuild switch --flake .#desktop
    nixosConfigurations = {
      desktop = import ./nixOS/desktop inputs;
    };
    # home-manager switch --flake .#macbook
    homeConfigurations = {
      macbook = import ./darwin/macbook.nix inputs;
      iris = import ./darwin/iris.nix {inherit inputs;};
    };
  };
}
