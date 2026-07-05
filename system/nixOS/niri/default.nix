{ inputs, pkgs, ... }:
{
  # niri-flake's module wires the compositor: package (niri-stable), the
  # niri-session, xdg portals, polkit, and session registration.
  imports = [ inputs.niri.nixosModules.niri ];

  programs.niri.enable = true;
  # git-main niri (newer than niri-flake's niri-stable tag). niri-flake doesn't
  # apply its overlay globally, so reference the flake output directly.
  programs.niri.package = inputs.niri.packages.${pkgs.system}.niri-unstable;

  # niri has built-in screenshots, so only wl-clipboard is extra (unlike sway,
  # which needs grim/slurp).
  environment.systemPackages = [ pkgs.wl-clipboard ];

  # Without this, swaylock falls back to pam.d/other (deny-all) and can never
  # unlock — a hard lockout. Registers /etc/pam.d/swaylock.
  security.pam.services.swaylock = { };
}
