{ inputs
, username
, ...
}: {
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.rev or inputs.dirtyRev or null;

  # Required by nix-darwin 25.11 for user-scoped options
  system.primaryUser = username;
}
