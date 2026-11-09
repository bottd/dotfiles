{ curl, writeJanet }:
writeJanet "tresorit-install" { runtimeInputs = [ curl ]; } (
  builtins.readFile ./tresorit-install.janet
)
