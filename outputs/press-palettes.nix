# Dither Press tokens (home/common/dither-press.nix) for every Glide host and
# appearance, keyed by variant name: `desktop-light`, `macbook-dark`, …. Loge
# hands them to drake.bot, which Glide's new tab opens with `?palette=<variant>`
# so the page matches the machine it's on.
{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory;

  home =
    host: variant:
    if host.format == "nixos" then
      self.nixosConfigurations.${variant}.config.home-manager.users.${host.username}
    else if host.format == "darwin" then
      self.darwinConfigurations.${variant}.config.home-manager.users.${host.username}
    else
      self.homeConfigurations.${variant}.config;
in
{
  flake.pressPalettes = lib.listToAttrs (
    lib.concatMap (
      host:
      lib.concatMap (
        appearance:
        let
          variant = "${host.hostName}-${appearance}";
          config = home host variant;
        in
        lib.optional (config.programs.glide-browser.enable or false) (
          lib.nameValuePair variant config.lib.ditherPress.tokens
        )
      ) host.appearances
    ) (builtins.attrValues inventory)
  );
}
