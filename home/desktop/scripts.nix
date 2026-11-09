{
  config,
  host,
  lib,
  pkgs,
  ...
}:
let
  scripts = import ./../../scripts { inherit pkgs; };
in
{
  xdg.configFile."dotfiles/host.json".text = builtins.toJSON {
    inherit (host) hostName format appearances;
    inherit (host.theme) appearance;
    flakeDirectory = "${config.home.homeDirectory}/dotfiles";
  };

  # Left off PATH: tresorit-install is a one-shot bootstrap run through
  # `nix run .#tresorit-install`, and the other two are only ever called by
  # store path (equibop's theme build, darwin's sign-apps activation).
  home.packages = builtins.attrValues (
    builtins.removeAttrs scripts (
      [
        "tresorit-install"
        "discord-ramp"
        "darwin-sign-apps"
      ]
      ++ lib.optionals pkgs.stdenv.isDarwin [
        "brightness"
        "games"
        "network"
        "niri-layout"
        "vpn"
      ]
    )
  );
}
