{ desktopEnvironment ? null, hostName, lib, ... }:
{
  # import GUI modules when desktop environment is present
  imports = lib.optionals (desktopEnvironment != null) [
    ./desktop.nix
    ./gaming.nix
  ] ++ lib.optionals (desktopEnvironment == "plasma") [
    ./plasma
  ] ++ lib.optionals (desktopEnvironment == "sway") [
    ./sway
  ] ++ lib.optionals (desktopEnvironment != null && desktopEnvironment != "sway") [
    ./${desktopEnvironment}/host/${hostName}.nix
  ];
}
