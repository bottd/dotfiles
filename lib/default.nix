{ inputs ? { }, ... }:
let
  versions = {
    home = "26.05";
    nixos = "25.05";
    darwin = 6;
  };

  # One nixpkgs-unstable instance per system, shared across every mkSystem
  # call — re-importing it per host re-evaluates the whole nixpkgs fixpoint.
  mkUnstable = system: import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };
  unstableFor = builtins.listToAttrs
    (map (s: { name = s; value = mkUnstable s; })
      [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]);

  mkSpecialArgs = { system, username, hostName ? null, theme ? { }, features ? { } }:
    let
      appearance = theme.appearance or "dark";
      t = {
        scheme = theme.scheme or "everforest";
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
    assert builtins.elem f.desktopEnvironment [ null "sway" "niri" "macos" ];
    {
      inherit inputs username system versions;
      theme = t;
      features = f;
      inherit (inputs) nixpkgs;
      nixpkgs-unstable = unstableFor.${system} or (mkUnstable system);
    }
    // (if hostName != null then { inherit hostName; inherit (inputs) nixos-hardware; } else { });

  mkSystem = import ./mkSystem.nix { inherit inputs versions mkSpecialArgs; };
in
{
  inherit mkSystem;
}
