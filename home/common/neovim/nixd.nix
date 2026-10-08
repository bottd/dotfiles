{
  config,
  inputs,
  host,
  lib,
  pkgs,
  ...
}:
let
  homeOnly = host.format == "home-manager";
  configurationType =
    if homeOnly then
      "homeConfigurations"
    else if host.format == "nixos" then
      "nixosConfigurations"
    else
      "darwinConfigurations";
  flakePath = if homeOnly then toString inputs.self else "${config.home.homeDirectory}/dotfiles";
  flake = "(builtins.getFlake ${builtins.toJSON flakePath})";
  hostConfig = "${flake}.${configurationType}.${builtins.toJSON host.hostName}";
  settings = {
    cmd = [ (lib.getExe pkgs.nixd) ];
    filetypes = [ "nix" ];
    root_markers = [
      "flake.nix"
      ".git"
    ];
    settings.nixd = {
      nixpkgs.expr = "${hostConfig}.pkgs";
      formatting.command = [ (lib.getExe pkgs.nixfmt) ];
      options =
        if homeOnly then
          {
            home-manager.expr = "${hostConfig}.options";
          }
        else
          {
            ${host.format}.expr = "${hostConfig}.options";
            home-manager.expr = "${hostConfig}.options.home-manager.users.type.getSubOptions []";
          };
    };
  };
in
{
  home.file.".config/nvim/lsp/nixd.lua".text = ''
    return vim.json.decode([==[${builtins.toJSON settings}]==])
  '';
}
