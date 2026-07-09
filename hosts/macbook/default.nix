{ inputs
, username
, ...
}: {
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.rev or inputs.dirtyRev or null;

  # Required by nix-darwin for user-scoped options
  system.primaryUser = username;

  users.users.${username}.home = "/Users/${username}";
}
