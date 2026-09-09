{ pkgs, ... }:
let
  inherit (pkgs) lib;
  writeJanet = pkgs.callPackage ../lib/writeJanet.nix { };

  janetScripts = prefix: dir:
    lib.concatMapAttrs
      (name: type:
        if type == "directory" then
          janetScripts "${prefix}${name}-" (dir + "/${name}")
        else if lib.hasSuffix ".janet" name then
          let
            base = lib.removeSuffix ".janet" name;
            scriptName = prefix + base;
            contents = builtins.readFile (dir + "/${name}");
            override = dir + "/${base}.nix";
            package =
              if builtins.pathExists override
              then pkgs.callPackage override { inherit writeJanet; }
              else writeJanet scriptName { } contents;
          in
          {
            ${scriptName} = package // {
              hasSelftest = lib.hasInfix ''"selftest"'' contents;
            };
          }
        else { })
      (builtins.readDir dir);
in
janetScripts "" ./.
