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

    neovim-nightly-overlay.url = "github:nix-community/neovim-nightly-overlay";
    nix-darwin.url = "github:LnL7/nix-darwin/master";
    nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    nixos-hardware.url = "github:nixos/nixos-hardware/master";
  };

  outputs = {...} @ inputs: rec {
    # darwin-rebuild switch --flake .#iris
    darwinConfigurations = {
      macbook = import ./darwin/macbook {
        inherit inputs;
      };
    };
    # sudo nixos-rebuild switch --flake .#desktop
    nixosConfigurations = {
      desktop = import ./nixOS/desktop {inherit inputs;};
      pocket = import ./nixOS/pocket {inherit inputs;};
    };
    # home-manager switch --flake .#iris
    homeConfigurations = {
      iris = import ./darwin/iris {inherit inputs;};
    };
  };
}
