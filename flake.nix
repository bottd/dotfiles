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
    # Define paths object
    paths = {
      root = ./.;
      # System paths
      system = ./system;
      systemHosts = ./system/hosts;
      systemModules = ./system/modules;
      # Home-manager paths
      home = ./home;
      homeCommon = ./home/common;
      homeDarwin = ./home/darwin;
      homeLinux = ./home/linux;
      homeHosts = ./home/hosts;
      # Utility paths
      util = ./util;
      # Configuration for nixOS hosts
      nixOS = ./nixOS;
    };

    # Standard home-manager config with consistent settings
    mkHomeConfig = {
      username,
      host,
      isLinux ? false,
      isDarwin ? false,
      extraImports ? [],
    }: {
      home-manager = {
        useGlobalPkgs = true;
        useUserPackages = true;
        extraSpecialArgs = {
          inherit inputs paths username;
          root = paths.root;
          neorgWorkspace = "chalet";
        };
        users.${username} = {
          imports =
            [
              (paths.root + "/home.nix")
              (paths.util + "/createSymlink.nix")
              paths.homeCommon
            ]
            ++ (
              if isLinux
              then [
                paths.homeLinux
                (paths.homeLinux + "/hyprland/host/${host}.nix")
              ]
              else if isDarwin
              then [
                paths.homeDarwin
              ]
              else []
            )
            ++ extraImports;
        };
      };
    };

    # Create a NixOS configuration with standard settings
    mkNixosSystem = {
      host,
      username,
      system ? "x86_64-linux",
      extraModules ? [],
    }:
      nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs paths username;
          host = host;
        };
        modules =
          [
            (paths.systemHosts + "/${host}")
            home-manager.nixosModules.home-manager
            (mkHomeConfig {
              inherit username host;
              isLinux = true;
            })
          ]
          ++ extraModules;
      };

    # Create a Darwin configuration with standard settings
    mkDarwinSystem = {
      host,
      username,
      system ? "aarch64-darwin",
      extraModules ? [],
    }:
      nix-darwin.lib.darwinSystem {
        inherit system;
        specialArgs = {
          inherit inputs paths username;
          host = host;
        };
        modules =
          [
            (paths.systemHosts + "/${host}")
            home-manager.darwinModules.home-manager
            (mkHomeConfig {
              inherit username host;
              isDarwin = true;
            })
          ]
          ++ extraModules;
      };
  in
    flake-parts.lib.mkFlake {inherit inputs;} {
      systems = ["x86_64-linux" "aarch64-darwin"];

      # Pass helper functions to modules
      _module.args = {
        inherit paths;
      };

      # Per-system configuration (formatter, devShells)
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

      # System configurations (NixOS, Darwin)
      flake = {
        # NixOS configurations
        nixosConfigurations = {
          # Desktop configuration
          desktop = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs paths;
              username = "drakeb";
              host = "desktop";
            };
            modules = [
              ./system/hosts/desktop
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs paths;
                    username = "drakeb";
                    root = ./.;
                    neorgWorkspace = "chalet";
                  };
                  users.drakeb = {
                    imports = [
                      ./home.nix
                      ./util/createSymlink.nix
                      ./home/linux
                      ./home/common
                    ];
                  };
                };
              }
            ];
          };

          # Pocket configuration
          pocket = nixpkgs.lib.nixosSystem {
            system = "x86_64-linux";
            specialArgs = {
              inherit inputs paths;
              username = "drakeb";
              host = "pocket";
            };
            modules = [
              ./system/hosts/pocket
              home-manager.nixosModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs paths;
                    username = "drakeb";
                    root = ./.;
                    neorgWorkspace = "chalet";
                  };
                  users.drakeb = {
                    imports = [
                      ./home.nix
                      ./util/createSymlink.nix
                      ./home/linux
                      ./home/common
                    ];
                  };
                };
              }
            ];
          };
        };

        # Darwin configurations
        darwinConfigurations = {
          # Macbook configuration
          macbook = nix-darwin.lib.darwinSystem {
            system = "aarch64-darwin";
            specialArgs = {
              inherit inputs paths;
              username = "drakebott";
              host = "macbook";
            };
            modules = [
              ./system/hosts/macbook
              home-manager.darwinModules.home-manager
              {
                home-manager = {
                  useGlobalPkgs = true;
                  useUserPackages = true;
                  extraSpecialArgs = {
                    inherit inputs paths;
                    username = "drakebott";
                    root = ./.;
                    neorgWorkspace = "chalet";
                  };
                  users.drakebott = {
                    imports = [
                      ./home.nix
                      ./util/createSymlink.nix
                      ./home/darwin
                      ./home/common
                    ];
                  };
                };
              }
            ];
          };
        };
      };
    };
}
