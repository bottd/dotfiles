{
  config,
  pkgs,
  inputs,
  ...
}: {
  nix.settings.experimental-features = "nix-command flakes";
  nixpkgs.config.allowUnfree = true;
  system.configurationRevision = inputs.rev or inputs.dirtyRev or null;
  system.stateVersion = 6;
  nixpkgs.hostPlatform = "aarch64-darwin";
}
