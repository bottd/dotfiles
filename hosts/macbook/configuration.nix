{ config
, inputs
, ...
}: {
  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set Git commit hash for darwin-version.
  system.configurationRevision = inputs.rev or inputs.dirtyRev or null;


  # The platform the configuration will be used on.
  nixpkgs.hostPlatform = "aarch64-darwin";
}
