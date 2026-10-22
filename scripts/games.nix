{
  lib,
  libnotify,
  stdenv,
  writeJanet,
}:
# aurelia itself is a flake input, not in pkgs, so the shell passes its path in
# AURELIA rather than this wrapper pinning it.
writeJanet "games" {
  runtimeInputs = lib.optionals stdenv.hostPlatform.isLinux [ libnotify ];
} (builtins.readFile ./games.janet)
