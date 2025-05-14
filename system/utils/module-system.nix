# Advanced module system with overrides and defaults
{lib, ...}: let
  # Define the type for a module with defaults and overrides
  moduleType = lib.types.submodule {
    options = {
      defaults = lib.mkOption {
        description = "Default module configuration";
        type = lib.types.attrs;
        default = {};
      };

      overrides = lib.mkOption {
        description = "Configuration overrides for specific situations";
        type = lib.types.attrs;
        default = {};
      };

      # Whether to enable this module
      enable = lib.mkOption {
        description = "Whether to enable this module";
        type = lib.types.bool;
        default = true;
      };
    };
  };

  # Helper function to merge a module with overrides
  mergeWithOverrides = defaults: overrides:
    lib.recursiveUpdate defaults overrides;

  # Helper function to create a new module
  mkModule = {
    defaults ? {},
    overrides ? {},
    enable ? true,
  }: {
    inherit defaults overrides enable;
  };

  # Helper function to get the final configuration for a module
  getModuleConfig = module:
    if module.enable
    then mergeWithOverrides module.defaults module.overrides
    else {};

  # Helper function to override a module's configuration
  overrideModule = module: newOverrides:
    module
    // {
      overrides = lib.recursiveUpdate module.overrides newOverrides;
    };

  # Helper function to set defaults for a module
  setDefaults = module: newDefaults:
    module
    // {
      defaults = lib.recursiveUpdate newDefaults module.defaults;
    };

  # Helper function to enable/disable a module
  setEnabled = module: isEnabled:
    module
    // {
      enable = isEnabled;
    };

  # Helper function to merge multiple modules
  mergeModules = modules:
    lib.foldl (
      acc: module:
        acc
        // {
          defaults = lib.recursiveUpdate acc.defaults module.defaults;
          overrides = lib.recursiveUpdate acc.overrides module.overrides;
          enable = acc.enable && module.enable;
        }
    ) (mkModule {})
    modules;
  # Return the final module system
in {
  # Types
  types = {
    module = moduleType;
  };

  # Module creation and manipulation
  inherit mkModule overrideModule setDefaults setEnabled mergeModules getModuleConfig;

  # Helper to create a config option for a module
  mkModuleOption = name: description:
    lib.mkOption {
      description = description;
      type = moduleType;
      default = mkModule {};
    };

  # Helper to merge defaults with overrides
  inherit mergeWithOverrides;
}
