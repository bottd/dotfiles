{
  description = "Drake Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Flake-parts framework
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
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
  };

  outputs = inputs @ {
    self,
    nixpkgs,
    home-manager,
    treefmt-nix,
    ...
  }: let
    system = "x86_64-linux";
    username = "drakeb";
  in {
    # Simplified NixOS configuration for desktop only
    nixosConfigurations = {
      desktop = nixpkgs.lib.nixosSystem {
        inherit system;
        specialArgs = {
          inherit inputs username;
          host = "desktop";
          paths = {
            root = ./.;
            system = ./system;
            systemModules = ./system/modules;
            home = ./home;
            homeCommon = ./home/common;
            homeDarwin = ./home/darwin;
            homeLinux = ./home/linux;
          };
        };
        modules = [
          # System configuration
          ./system/hosts/desktop

          # Home manager module
          home-manager.nixosModules.home-manager
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs username;
                paths = {
                  root = ./.;
                  system = ./system;
                  systemModules = ./system/modules;
                  home = ./home;
                  homeCommon = ./home/common;
                  homeDarwin = ./home/darwin;
                  homeLinux = ./home/linux;
                };
                root = ./.;
                neorgWorkspace = "chalet";
              };
              users.${username} = {
                imports = [
                  # Home configuration
                  ./home.nix

                  # Utility functions
                  ./util/createSymlink.nix

                  # Platform and feature-specific modules - using direct paths until path resolution is fixed
                  ./home/linux
                  ./home/linux/hyprland/host/desktop.nix
                  ./home/common
                ];
              };
            };
          }
        ];
      };
    };

    # Add formatter for 'nix fmt' command
    formatter.${system} =
      treefmt-nix.lib.mkWrapper
      nixpkgs.legacyPackages.${system}
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

    devShells.${system}.default = nixpkgs.legacyPackages.${system}.mkShell {
      buildInputs = with nixpkgs.legacyPackages.${system}; [
        git
        self.formatter.${system}
      ];

      shellHook = ''
        echo "🚀 Welcome to Drake's dotfiles dev shell"
        echo "Use 'treefmt' to format the code, replacing alejandra"
      '';
    };
  };
}
