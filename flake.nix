{
  description = "Drake Flake";
  inputs = {
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    mac-app-util.url = "github:hraban/mac-app-util";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
  };

  outputs = {...} @ inputs: rec {
    # home-manager switch --flake .#iris
    homeConfigurations = {
      fedora = import ./hosts/fedora {inherit inputs;};
      iris = import ./hosts/iris {inherit inputs;};
    };
  };
}
