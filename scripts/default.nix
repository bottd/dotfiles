{ pkgs, ... }:
let
  inherit (pkgs) lib;

  # Every .clj under this directory becomes a script bin, named after its path:
  # `rebuild.clj` -> `rebuild`, `waybar/mullvad.clj` -> `waybar-mullvad`.
  #
  # A sibling `foo.nix` next to `foo.clj` wins: scripts needing more than a
  # plain wrap (@placeholder@ substitution, extra inputs) build from there
  # instead, so nothing has to be listed by name to opt out.
  cljScripts = prefix: dir:
    lib.concatMapAttrs
      (name: type:
        if type == "directory" then
          cljScripts "${prefix}${name}-" (dir + "/${name}")
        else if lib.hasSuffix ".clj" name then
          let
            scriptName = prefix + lib.removeSuffix ".clj" name;
            override = dir + "/${lib.removeSuffix ".clj" name}.nix";
          in
          {
            ${scriptName} =
              if builtins.pathExists override
              then pkgs.callPackage override { }
              else pkgs.writers.writeBabashkaBin scriptName { } (builtins.readFile (dir + "/${name}"));
          }
        else { })
      (builtins.readDir dir);
in
cljScripts "" ./.
