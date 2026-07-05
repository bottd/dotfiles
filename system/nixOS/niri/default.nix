{ inputs, pkgs, ... }:
{
  # niri-flake's module wires everything: niri-session, xdg portals, a polkit
  # agent, the swaylock PAM service, and the niri.cachix.org substituter.
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri = {
    enable = true;
    # git-main niri. niri-flake doesn't apply its overlay globally, so reference
    # the flake output directly (this is what niri.cachix.org caches).
    package = inputs.niri.packages.${pkgs.system}.niri-unstable;
  };
}
