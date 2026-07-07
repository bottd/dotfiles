{
  description = "Mark's nix-darwin flake";
  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-26.05";
    nixpkgs-unstable.url = "github:nixos/nixpkgs/nixpkgs-unstable";
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
      systems = [ "aarch64-darwin" ];

      imports = [
        ./outputs
      ];
    };
}
