{ features, lib, autologin, ... }:
{
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
    ./stylix.nix
  ] ++ lib.optionals features.gaming [
    ./gaming.nix
  ] ++ lib.optionals (features.desktopEnvironment == "niri") ([
    ./niri
    # greetd drops straight into niri-session; sddm gives a themed password
    # prompt (and, on pocket, is the only greeter that can rotate itself).
  ] ++ (if autologin then [ ./greetd.nix ] else [ ./sddm.nix ]));
}
