{ pkgs, ... }:
let
  inherit (pkgs) lib;

  # Every .clj under this directory becomes a script bin, named after its path:
  # `rebuild.clj` -> `rebuild`, `waybar/mullvad.clj` -> `waybar-mullvad`.
  cljScripts = prefix: dir:
    lib.concatMapAttrs
      (name: type:
        if type == "directory" then
          cljScripts "${prefix}${name}-" (dir + "/${name}")
        else if lib.hasSuffix ".clj" name then
          let scriptName = prefix + lib.removeSuffix ".clj" name;
          in { ${scriptName} = pkgs.writers.writeBabashkaBin scriptName { } (builtins.readFile (dir + "/${name}")); }
        else { })
      (builtins.readDir dir);
in
cljScripts "" ./.
