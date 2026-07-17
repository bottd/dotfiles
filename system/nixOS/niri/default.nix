{ inputs, pkgs, ... }:
{
  # niri-flake's module wires everything: niri-session, xdg portals, a polkit
  # agent, the swaylock PAM service, and the niri.cachix.org substituter.
  imports = [ inputs.niri.nixosModules.niri ];

  # Tap Super to emit F13 while preserving Super as the modifier for chords.
  services.keyd = {
    enable = true;
    keyboards.default = {
      ids = [ "*" ];
      settings = {
        global.overload_tap_timeout = 200;
        main.meta = "overload(meta, f13)";
      };
    };
  };

  programs.niri = {
    enable = true;
    # git-main niri. niri-flake doesn't apply its overlay globally, so reference
    # the flake output directly (this is what niri.cachix.org caches).
    package = inputs.niri.packages.${pkgs.stdenv.hostPlatform.system}.niri-unstable;
  };
}
