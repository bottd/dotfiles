{ inputs ? { }, ... }:
let
  # One nixpkgs-unstable instance per system, shared across every mkSystem
  # call — re-importing it per host re-evaluates the whole nixpkgs fixpoint.
  unstableFor = inputs.nixpkgs.lib.genAttrs
    [ "x86_64-linux" "aarch64-linux" "aarch64-darwin" ]
    (system: import inputs.nixpkgs-unstable {
      inherit system;
      config.allowUnfree = true;
    });

  mkSpecialArgs = { system, username, hostName, theme ? { }, features ? { } }:
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
    assert builtins.elem f.desktopEnvironment [ null "niri" "macos" ];
    {
      inherit inputs username system hostName;
      theme = t;
      features = f;
      nixpkgs-unstable = unstableFor.${system};
    };

  mkSystem = import ./mkSystem.nix { inherit inputs mkSpecialArgs; };
in
{
  inherit mkSystem;
}
