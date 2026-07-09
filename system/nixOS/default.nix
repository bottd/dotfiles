{ features, lib, autologin, ... }:
{
  # The grub target only exists in stylix's NixOS module set, so it can't live
  # in the shared ../common/stylix.nix (module structure can't branch on pkgs).
  stylix.targets.grub.enable = false;

  imports = [
    ../common/nix.nix
    ./audio.nix
    ./bluetooth.nix
    ./cli.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
    ../common/stylix.nix
  ] ++ lib.optionals features.gaming [
    ./gaming.nix
  ] ++ lib.optionals (features.desktopEnvironment == "niri") ([
    ./niri
    # greetd drops straight into niri-session; sddm gives a themed password
    # prompt (and, on pocket, is the only greeter that can rotate itself).
  ] ++ (if autologin then [ ./greetd.nix ] else [ ./sddm.nix ]));
}
