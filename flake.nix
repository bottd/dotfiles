{
  description = "Drake Flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    stylix = {
      url = "github:nix-community/stylix/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixpkgs-unstable = {
      url = "github:nixos/nixpkgs/nixpkgs-unstable";
    };
    flake-parts = {
      url = "github:hercules-ci/flake-parts";
      inputs.nixpkgs-lib.follows = "nixpkgs";
    };
    home-manager = {
      url = "github:nix-community/home-manager/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-darwin = {
      url = "github:nix-darwin/nix-darwin/nix-darwin-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    treefmt-nix = {
      url = "github:numtide/treefmt-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pre-commit-hooks = {
      url = "github:cachix/git-hooks.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    spicetify-nix = {
      url = "github:Gerg-L/spicetify-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    steam-config-nix = {
      url = "github:different-name/steam-config-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nixos-hardware.url = "github:NixOS/nixos-hardware/master";
    nixos-avf = {
      url = "github:nix-community/nixos-avf";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    nix-tresorit = {
      url = "github:p15r/nix-tresorit/release-26.05";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    glide = {
      url = "github:glide-browser/glide.nix";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.home-manager.follows = "home-manager";
    };
    # niri compositor: NixOS + home-manager modules with build-time config
    # validation. Keeps its own nixpkgs pin so its binary cache stays hit.
    niri.url = "github:sodiboo/niri-flake";
    # Minecraft-styled SDDM theme (pocket's greeter). We take `packages.default`
    # only, not `nixosModules.default` — that module installs Qt5 deps, but the
    # theme is Theme-API 2.0 / QtVersion=6 and nixpkgs' sddm is Qt6.
    minesddm = {
      url = "github:Davi-S/sddm-theme-minesddm";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    mac-app-util = {
      # Pinned to nixos-25.11 (sbcl 2.5.10) instead of following our nixos-26.05:
      # 26.05's sbcl 2.6.4 breaks cl-nix-lite's fare-quasiquote build
      url = "github:hraban/mac-app-util";
      inputs.nixpkgs.url = "github:nixos/nixpkgs/nixos-25.11";
    };
    # Keeps its own nixpkgs pin so its cachix cache stays hit.
    claude-code.url = "github:sadjow/claude-code-nix";
  };

  outputs = inputs @ { flake-parts, ... }:
    flake-parts.lib.mkFlake { inherit inputs; } {
      systems = [ "x86_64-linux" "aarch64-darwin" ];

      imports = [
        ./outputs
      ];
    };
}
