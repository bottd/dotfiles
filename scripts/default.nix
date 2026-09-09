{ pkgs, ... }:
let
  inherit (pkgs) lib;
  writeJanet = pkgs.callPackage ../lib/writeJanet.nix { };

  # Every .janet under this directory becomes a script bin, named after its path:
  # `rebuild.janet` -> `rebuild`, `waybar/mullvad.janet` -> `waybar-mullvad`.
  #
  # A sibling `foo.nix` next to `foo.janet` wins: scripts needing more than a
  # plain wrap (@placeholder@ substitution, extra inputs) build from there
  # instead, so nothing has to be listed by name to opt out.
  janetScripts = prefix: dir:
    lib.concatMapAttrs
      (name: type:
        if type == "directory" then
          janetScripts "${prefix}${name}-" (dir + "/${name}")
        else if lib.hasSuffix ".janet" name then
          let
            scriptName = prefix + lib.removeSuffix ".janet" name;
            override = dir + "/${lib.removeSuffix ".janet" name}.nix";
          in
          {
            ${scriptName} =
              if builtins.pathExists override
              then pkgs.callPackage override { inherit writeJanet; }
              else writeJanet scriptName { } (builtins.readFile (dir + "/${name}"));
          }
        else { })
      (builtins.readDir dir);
in
janetScripts "" ./.
