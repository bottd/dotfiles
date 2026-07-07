{ inputs ? { }, ... }:
let
  versions = {
    home = "26.05";
    darwin = 6;
  };

  system = "aarch64-darwin";

  # One nixpkgs-unstable instance, shared across every builder call —
  # re-importing it per host re-evaluates the whole nixpkgs fixpoint.
  unstable = import inputs.nixpkgs-unstable {
    inherit system;
    config.allowUnfree = true;
  };

  # The home-manager modules every profile gets, whether deployed via
  # nix-darwin (mkSystem) or standalone home-manager (mkHome).
  homeImports = [
    ../home.nix
    ../lib/createSymlink.nix
    ../home/common
    ../home/darwin
  ];

  mkSpecialArgs = { username, hostName, theme ? { }, features ? { } }:
    let
      appearance = theme.appearance or "dark";
      t = {
        scheme = theme.scheme or "everforest";
        inherit appearance;
        baseFontSize = theme.baseFontSize or 12;
      };
      f = {
        gui = features.gui or true;
        desktopEnvironment = features.desktopEnvironment or null;
      };
    in
    assert builtins.elem t.appearance [ "light" "dark" ];
    assert builtins.elem f.desktopEnvironment [ null "macos" ];
    {
      inherit inputs username system versions hostName;
      theme = t;
      features = f;
      inherit (inputs) nixpkgs;
      nixpkgs-unstable = unstable;
    };

  mkSystem = import ./mkSystem.nix { inherit inputs versions mkSpecialArgs homeImports system; };

  # Standalone home-manager — for machines where you can't (or don't want to)
  # manage the whole system with nix-darwin, e.g. a locked-down work Mac.
  mkHome = { username, hostName ? "standalone", theme ? { }, features ? { }, extraHomeModules ? [ ] }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = import inputs.nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };
      extraSpecialArgs = mkSpecialArgs { inherit username hostName theme features; };
      modules = homeImports ++ extraHomeModules;
    };
in
{
  inherit mkSystem mkHome;
}
