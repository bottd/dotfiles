# OOM protection settings to prevent build failures
# Particularly useful for systems with limited memory
{
  pkgs,
  lib,
  ...
}: {
  # OOM configuration to prevent build failures
  systemd = {
    # Create a separate slice for nix-daemon that is
    # memory-managed by the userspace systemd-oomd killer
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services."nix-daemon".serviceConfig.Slice = "nix-daemon.slice";

    # If a kernel-level OOM event does occur, prefer killing nix-daemon
    services."nix-daemon".serviceConfig.OOMScoreAdjust = 1000;
  };
}
