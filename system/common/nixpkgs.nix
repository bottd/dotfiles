{ pkgs, ... }:
{
  # bitwarden-desktop and signal-desktop have insecure Electron and pnpm
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "pnpm" "electron" ];
}
