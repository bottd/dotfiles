{ pkgs, ... }:
{
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "claude-code" ];

  # bitwarden-desktop and signal-desktop have insecure Electron and pnpm
  nixpkgs.config.allowInsecurePredicate = pkg:
    builtins.elem (pkgs.lib.getName pkg) [ "pnpm" "electron" ];
}
