{ inputs ? { }, ... }:
let
  versions = {
    home = "25.05";
    nixos = "25.05";
    darwin = 6;
  };

  mkSpecialArgs = { system, username, hostName ? null, theme ? { }, features ? { } }:
    let
      appearance = theme.appearance or "dark";
      t = {
        scheme = theme.scheme or "oxocarbon";
        inherit appearance;
        baseFontSize = theme.baseFontSize or 20;
      };
      f = {
        gui = features.gui or true;
        gaming = features.gaming or false;
        desktopEnvironment = features.desktopEnvironment or null;
      };
    in
    assert builtins.elem t.appearance [ "light" "dark" ];
    assert t.scheme == "oxocarbon";
    assert builtins.elem f.desktopEnvironment [ null "plasma" "niri" "sway" "macos" ];
    {
      inherit inputs username system versions;
      theme = t;
      features = f;
      inherit (inputs) nixpkgs;
      nixpkgs-unstable = import inputs.nixpkgs-unstable {
        inherit system;
        config.allowUnfree = true;
      };
    }
    // (if hostName != null then { inherit hostName; inherit (inputs) nixos-hardware; } else { });

  createSymlink = import ./createSymlink.nix;
  mkHome = import ./mkHome.nix { inherit inputs mkSpecialArgs; };
  mkSystem = import ./mkSystem.nix { inherit inputs versions mkSpecialArgs; };
in
{
  inherit createSymlink mkHome mkSystem versions;
}
