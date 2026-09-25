{ pkgs, ... }:
{
  home.packages = [
    (pkgs.writeShellScriptBin "tailscale" ''
      exec /Applications/Tailscale.app/Contents/MacOS/Tailscale "$@"
    '')
  ];
}
