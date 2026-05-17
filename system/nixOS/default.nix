{ features, lib, ... }:
let
  de = features.desktopEnvironment;
  deModules = {
    niri = ./niri;
    plasma = ./plasma;
    sway = ./sway;
    quote = ./quote;
  };
  # quote uses lightdm (awesome is X11, autologin via services.displayManager)
  useGreetd = de != null && de != "quote";
in
{
  imports = [
    ./audio.nix
    ./bluetooth.nix
    ./cli.nix
    ./graphics.nix
    ./jellyfin.nix
    ./keyring.nix
    ./mullvad.nix
    ./printing.nix
    ./stylix.nix
    ./webcam.nix
  ]
  ++ lib.optional useGreetd ./greetd.nix
  ++ lib.optionals features.gaming [ ./gaming.nix ]
  ++ lib.optional (deModules ? ${de}) deModules.${de};
}
