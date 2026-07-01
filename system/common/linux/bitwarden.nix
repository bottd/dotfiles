{ pkgs, ... }:
{
  # bitwarden-desktop has insecure Electron and pnpm
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "pnpm" "electron" ];
}
