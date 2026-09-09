{ lib, callPackage, janet, coreutils, writers }:
let
  modules = callPackage ../packages/janet { };
  checkJanet = callPackage ./checkJanet.nix { };
in
name: { runtimeInputs ? [ ] }: content:
writers.makeScriptWriter
{
  interpreter = lib.getExe janet;
  check = checkJanet;
  makeWrapperArgs = [
    "--set"
    "JANET_PATH"
    "${modules}/lib"
    "--unset"
    "JANET_PROFILE"
    "--prefix"
    "PATH"
    ":"
    (lib.makeBinPath ([ coreutils ] ++ runtimeInputs))
  ];
}
  "/bin/${name}"
  content
