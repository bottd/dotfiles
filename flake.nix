{
  description = "Drake Flake";
  inputs = {
    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {
    home-manager,
    nixpkgs,
    ...
  } @ inputs: rec {
    # home-manager switch --flake .#mena
    homeConfigurations = {
      mena = import ./mena {inherit inputs home-manager nixpkgs;};
    };
  };
}
