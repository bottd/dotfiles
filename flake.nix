{
  description = "Mena Flake";
  inputs = {
    ghostty = {
      url = "github:ghostty-org/ghostty";
    };

    home-manager = {
      url = "github:nix-community/home-manager";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    nixpkgs.url = "github:NixOS/nixpkgs/release-24.11";
  };

  outputs = {home-manager, ...} @ inputs: rec {
    # home-manager switch --flake .#mena
    homeConfigurations = {
      mena = home-manager.lib.homeManagerConfiguration {
        extraSpecialArgs = {
          username = "mena";
          root = ./.;
        };
        modules = [
          ./util/default.nix
          ./home.nix
          ./home/default.nix
        ];
      };
    };
  };
}
