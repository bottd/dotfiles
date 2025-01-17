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

  outputs = inputs@{ self, home-manager, mac-app-util, nixos-hardware, nixpkgs, ... }: {
    # sudo nixos-rebuild switch --flake .#desktop
    nixosConfigurations = {
      desktop = import ./nixOS/desktop {inherit home-manager inputs nixpkgs;};
    };
    # home-manager switch --flake .#macbook
    homeConfigurations = {
      macbook = import ./darwin/macbook.nix {inherit home-manager inputs mac-app-util nixpkgs;};
      iris = import ./darwin/iris.nix {inherit home-manager inputs mac-app-util nixpkgs;};
    };
  };
}
