{
  git,
  nh,
  writeJanet,
}:
writeJanet "rebuild" {
  runtimeInputs = [
    git
    nh
  ];
} (builtins.readFile ./rebuild.janet)
