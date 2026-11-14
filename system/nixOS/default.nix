{
  features,
  lib,
  autologin,
  ...
}:
{
  # The grub target only exists in stylix's NixOS module set, so it can't live
  # in the shared ../common/stylix.nix (module structure can't branch on pkgs).
  stylix.targets.grub.enable = false;

  # Used for working with Android MTP
  services.gvfs.enable = features.desktopApps;

  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./cli.nix
    ./graphics.nix
    ./keyring.nix
    ./tailscale.nix
    ./printing.nix
    ../common/stylix.nix
  ]
  ++ lib.optionals features.gaming [
    ./gaming.nix
  ]
  # Every Linux desktop (niri or mango) imports the niri module: it carries
  # keyd, the polkit agent, the swaylock PAM service, and the home-manager
  # options the shell config uses. greetd drops straight into the session; sddm
  # gives a themed password prompt (and, on pocket, is the only greeter that
  # can rotate itself).
  ++ lib.optionals (features.desktopEnvironment != null) [
    ./niri
    (if autologin then ./greetd.nix else ./sddm.nix)
  ]
  ++ lib.optional (features.desktopEnvironment == "mango") ./mango.nix;
}
