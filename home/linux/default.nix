{ features, hostName, lib, ... }:
let
  de = features.desktopEnvironment;
  selfContained = {
    plasma = ./plasma;
    sway = ./sway;
    quote = ./quote;
  };
  perHost = lib.optional
    (de != null && !(selfContained ? ${de}))
    ./${de}/host/${hostName}.nix;
in
{
  imports = [
    ./theme.nix
  ]
  ++ lib.optionals features.gui [ ./desktop.nix ./mpv ]
  ++ lib.optionals features.gaming [ ./games ]
  ++ lib.optional (de != null && selfContained ? ${de}) selfContained.${de}
  ++ perHost;
}
