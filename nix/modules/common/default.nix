# Common utilities and functions for the flake
{inputs, ...}: {
  # This module exposes helper functions but doesn't produce any outputs directly
  _module.args = {
    # Helper function to create paths object for system configurations
    mkPaths = self: {
      root = self;
      system = self + "/system";
      systemModules = self + "/system/modules";
      home = self + "/home";
      homeCommon = self + "/home/common";
      homeDarwin = self + "/home/darwin";
      homeLinux = self + "/home/linux";
    };
  };
}
