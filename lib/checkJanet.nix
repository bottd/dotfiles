{ lib, callPackage, janet }:
let
  modules = callPackage ../packages/janet { };
in
# Unlike -k, :exit true makes parsing and compilation errors fail the process.
"${lib.getExe janet} -R -m ${modules}/lib -x normal -E '(flycheck $ :exit true)'"
