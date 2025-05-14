# Basic settings specific to Darwin systems
{ inputs, ... }: {
  # Track configuration revision
  system.configurationRevision = inputs.rev or inputs.dirtyRev or null;

  # Standard state version for Darwin
  system.stateVersion = 6;

  # Ensure platform is set correctly
  nixpkgs.hostPlatform = "aarch64-darwin";
}
