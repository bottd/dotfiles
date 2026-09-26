{ inputs
, username
, ...
}: {
  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.self.rev or inputs.self.dirtyRev or null;

  # Required by nix-darwin for user-scoped options
  system.primaryUser = username;

  users.users.${username}.home = "/Users/${username}";
}
