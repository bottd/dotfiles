{
  description = "Drake Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:LnL7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    ghostty.url = "github:ghostty-org/ghostty";
    mac-app-util.url = "github:hraban/mac-app-util";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {flake-parts, ...}:
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = [
        "x86_64-linux"
        "aarch64-darwin"
      ];

      imports = [
      ];

      flake = rec {
        darwinConfigurations = {
          macbook = import ./darwin/macbook {
            inherit inputs;
          };
        };

        nixosConfigurations = {
          desktop = import ./nixOS/desktop {inherit inputs;};
          pocket = import ./nixOS/pocket {inherit inputs;};
        };

        homeConfigurations = {
          iris = import ./darwin/iris {inherit inputs;};
        };
      };

      perSystem = {
        config,
        pkgs,
        system,
        ...
      }: {
        packages = {};

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
          ];

          shellHook = ''
            echo "🚀 Welcome to Drake's dotfiles dev shell"
          '';
        };
      };
    };
}
