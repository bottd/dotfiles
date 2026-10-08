{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory;
in
{
  # `nix flake check` evaluates every host in one process (~6G); CI builds the
  # checks through this instead and evaluates hosts one at a time below.
  perSystem =
    { config, pkgs, ... }:
    {
      legacyPackages.ciChecks = pkgs.linkFarm "ci-checks" config.checks;
    };

  # Every host and appearance variant, evaluated to a drvPath but never built.
  # CI runs on a single x86_64-linux VPS, so this is how the aarch64 and darwin
  # hosts still get checked. Each takes ~2G alone versus ~8G all at once.
  flake.ci.drvPaths = lib.listToAttrs (
    lib.concatMap (
      host:
      map (
        variant:
        lib.nameValuePair variant (
          if host.format == "nixos" then
            self.nixosConfigurations.${variant}.config.system.build.toplevel.drvPath
          else if host.format == "home-manager" then
            self.homeConfigurations.${variant}.activationPackage.drvPath
          else
            self.darwinConfigurations.${variant}.system.drvPath
        )
      ) ([ host.hostName ] ++ map (appearance: "${host.hostName}-${appearance}") host.appearances)
    ) (builtins.attrValues inventory)
  );
}
