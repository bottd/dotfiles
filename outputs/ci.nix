{ inputs, self, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory;
in
{
  # Every host and appearance variant, evaluated to a drvPath but never built.
  # CI runs on a single x86_64-linux VPS, so this is how the aarch64 and darwin
  # hosts still get checked: `nix eval --json .#ci.drvPaths`.
  flake.ci.drvPaths = lib.listToAttrs (
    lib.concatMap (
      host:
      map (
        variant:
        lib.nameValuePair variant (
          if host.format == "nixos" then
            self.nixosConfigurations.${variant}.config.system.build.toplevel.drvPath
          else
            self.darwinConfigurations.${variant}.system.drvPath
        )
      ) ([ host.hostName ] ++ map (appearance: "${host.hostName}-${appearance}") host.appearances)
    ) (builtins.attrValues inventory)
  );
}
