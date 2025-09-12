# OOM management configuration
# https://discourse.nixos.org/t/nix-build-ate-my-ram/35752
{
  systemd = {
    # Create a separate slice for nix-daemon that is
    # memory-managed by the userspace systemd-oomd killer
    slices."nix-daemon".sliceConfig = {
      ManagedOOMMemoryPressure = "kill";
      ManagedOOMMemoryPressureLimit = "50%";
    };
    services."nix-daemon".serviceConfig = {
      Slice = "nix-daemon.slice";
      # If a kernel-level OOM event does occur anyway,
      # strongly prefer killing nix-daemon child processes
      OOMScoreAdjust = 1000;
    };
  };
}
