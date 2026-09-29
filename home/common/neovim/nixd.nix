{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  configurationType =
    if host.format == "nixos" then "nixosConfigurations" else "darwinConfigurations";
  flake = "(builtins.getFlake ${builtins.toJSON "${config.home.homeDirectory}/dotfiles"})";
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
      options = {
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
