{
  lib,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    vscode
    vscode-extension-catppuccin-catppuccin-vsc
  ];
}
