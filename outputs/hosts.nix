{ inputs, ... }:
let
  inherit (import ../lib { inherit inputs; }) mkSystem mkHome;

  # Change this to your macOS username.
  username = "mark";
in
{
  flake = {
    # Full system, managed with nix-darwin:
    #   darwin-rebuild switch --flake .#darwin
    darwinConfigurations.darwin = mkSystem {
      hostName = "darwin";
      system = "aarch64-darwin";
      inherit username;
      features.desktopEnvironment = "macos";
      theme = { appearance = "dark"; baseFontSize = 12; };
    };

    # User-level only, for a machine where you can't run nix-darwin
    # (e.g. a work Mac). Managed with standalone home-manager:
    #   home-manager switch --flake .#standalone
    homeConfigurations.standalone = mkHome {
      inherit username;
      theme = { appearance = "dark"; baseFontSize = 12; };
    };
  };
}
