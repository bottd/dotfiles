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
      url = "github:LnL7/nix-darwin";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    ghostty.url = "github:ghostty-org/ghostty";
    zen-browser = {
      url = "github:0xc000022070/zen-browser-flake";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    flake-parts,
    home-manager,
    nix-darwin,
    treefmt-nix,
    ...
  }: let
    lib = import ./lib {inherit inputs;};
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      perSystem = {
        config,
        self',
        inputs',
        pkgs,
        system,
        ...
      }: {
        formatter =
          treefmt-nix.lib.mkWrapper
          pkgs
          {
            projectRootFile = "flake.nix";
            programs = {
              nixpkgs-fmt.enable = true;
              stylua.enable = true;
              shfmt.enable = true;
              beautysh.enable = true;
              deadnix.enable = true;
              taplo.enable = true;
            };
          };

        devShells.default = pkgs.mkShell {
          buildInputs = with pkgs; [
            git
            self'.formatter
          ];

          shellHook = ''
            echo "🚀 Welcome to Drake's dotfiles dev shell"
            echo "Use 'treefmt' to format the code, replacing alejandra"
          '';
        };
      };

      flake = {
        nixosConfigurations = {
          desktop = lib.mkSystem {
            hostName = "desktop";
            extraModules = [
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    neorgWorkspace = "chalet";
                    root = ./.;
                  };
                };
              }
            ];
          };

          pocket = lib.mkSystem {
            hostName = "pocket";
            extraModules = [
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    neorgWorkspace = "chalet";
                    root = ./.;
                  };
                };
              }
            ];
          };
        };

        darwinConfigurations = {
          macbook = lib.mkSystem {
            hostName = "macbook";
            extraModules = [
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    neorgWorkspace = "chalet";
                    root = ./.;
                  };
                };
              }
            ];
          };
        };

        homeConfigurations = {
          iris = lib.mkHome {
            hostName = "iris";
            extraModules = [
              ./lib/createSymlink.nix
              ./home/common
              ./home/darwin
            ];
          };
        };
      };
    };
}
