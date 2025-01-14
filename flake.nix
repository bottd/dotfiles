{
  description = "Drake Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
    mac-app-util.url = "github:hraban/mac-app-util";

    home-manager = {
      url = "github:nix-community/home-manager/release-24.11";
      inputs.nixpkgs.follows = "nixpkgs";
    }
  };

  outputs = inputs@{ self, flake-parts, home-manager, mac-app-util, nixos-hardware, nixpkgs, ... }: {
    # sudo nixos-rebuild switch --flake .#desktop
    nixosConfigurations = {
      desktop = import ./nixOS/desktop.nix {inherit inputs;};
    };
    # home-manager switch --flake .#drakebott
    packages.aarch64-darwin.homeConfigurations = {
      drakebott = import ./darwin/personal.nix {inherit inputs;};
    };
  };
}
