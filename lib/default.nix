{ inputs ? { }, ... }:
let
  versions = {
    home = "25.05";
    nixos = "25.05";
    darwin = 6;
  };

  mkSpecialArgs = { system, username, desktopEnvironment ? null, hostName ? null, includeGui ? true, includeGaming ? false, colorScheme ? "light", stylixTheme ? "catppuccin", baseFontSize ? 20 }:
    assert builtins.elem colorScheme [ "light" "auto" ];
    assert builtins.elem stylixTheme [ "catppuccin" "eink" ];
    {
      inherit inputs username system desktopEnvironment versions colorScheme stylixTheme baseFontSize;
      inherit (inputs) nixpkgs;
      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    }
    // (if hostName != null then { inherit hostName includeGui includeGaming; inherit (inputs) nixos-hardware; } else { });

  createSymlink = import ./createSymlink.nix;
  mkHome = import ./mkHome.nix { inherit inputs mkSpecialArgs; };
  mkSystem = import ./mkSystem.nix { inherit inputs versions mkSpecialArgs; };
in
{
  inherit createSymlink mkHome mkSystem versions;
}
