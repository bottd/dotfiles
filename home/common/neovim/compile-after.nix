{ lib, callPackage, luajitPackages, runCommand }:
let
  writeJanet = callPackage ../../../lib/writeJanet.nix { };
  compiler = writeJanet "compile-after"
    { runtimeInputs = [ luajitPackages.fennel ]; }
    (builtins.readFile ./compile-after.janet);
in
runCommand "nvim-after" { } ''
  ${lib.getExe compiler} ${./after} $out
''
