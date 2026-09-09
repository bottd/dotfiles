{ brightnessctl, ddcutil, flock, lib, stdenv, writeJanet }:
# The script chooses its backend from what the host actually has, so both tools
# have to be on PATH: a missing binary is indistinguishable from a missing
# display, and would degrade to a silently blank brightness module.
writeJanet "brightness"
{
  # Common scripts are also installed on Darwin, where neither backend exists.
  runtimeInputs = [ flock ] ++ lib.optionals stdenv.hostPlatform.isLinux [ brightnessctl ddcutil ];
}
  (builtins.readFile ./brightness.janet)
