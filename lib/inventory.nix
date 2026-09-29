{ lib }:
definitions:
let
  inherit (lib) mkOption types;
  appearance = types.enum [
    "light"
    "dark"
  ];
  release = types.strMatching "[0-9]{2}\\.[0-9]{2}";
  evaluated = lib.evalModules {
    modules = [
      {
        options.hosts = mkOption {
          type = types.attrsOf (
            types.submodule (
              { name, config, ... }: {
                options = {
                  hostName = mkOption {
                    type = types.str;
                    readOnly = true;
                    default = name;
                  };
                  system = mkOption {
                    type = types.enum [
                      "x86_64-linux"
                      "aarch64-linux"
                      "aarch64-darwin"
                    ];
                  };
                  format = mkOption {
                    type = types.enum [
                      "nixos"
                      "darwin"
                    ];
                  };
                  username = mkOption { type = types.nonEmptyStr; };
                  autologin = mkOption {
                    type = types.bool;
                    default = false;
                  };
                  enableAVF = mkOption {
                    type = types.bool;
                    default = false;
                  };
                  extraHomeModules = mkOption {
                    type = types.listOf types.path;
                    default = [ ];
                  };
                  extraSystemModules = mkOption {
                    type = types.listOf types.path;
                    default = [ ];
                  };
                  appearances = mkOption {
                    type = types.listOf appearance;
                    default = [
                      "light"
                      "dark"
                    ];
                  };
                  stateVersion = {
                    system = mkOption { type = types.either release types.ints.positive; };
                    home = mkOption { type = release; };
                  };
                  theme = {
                    appearance = mkOption {
                      type = appearance;
                      default = "light";
                    };
                    scheme = mkOption {
                      type = types.nonEmptyStr;
                      default = "melange";
                    };
                    baseFontSize = mkOption {
                      type = types.ints.positive;
                      default = 12;
                    };
                  };
                  features = {
                    desktopEnvironment = mkOption {
                      type = types.nullOr (
                        types.enum [
                          "niri"
                          "macos"
                        ]
                      );
                      default = null;
                    };
                    desktopApps = mkOption {
                      type = types.bool;
                      default = config.features.desktopEnvironment != null;
                    };
                    animations = mkOption {
                      type = types.bool;
                      default = config.features.desktopApps;
                    };
                    gaming = mkOption {
                      type = types.bool;
                      default = false;
                    };
                  };
                  nix = {
                    maxJobs = mkOption {
                      type = types.either types.ints.unsigned (types.enum [ "auto" ]);
                      default = "auto";
                    };
                    cores = mkOption {
                      type = types.ints.unsigned;
                      default = 0;
                    };
                    keepOutputs = mkOption {
                      type = types.bool;
                      default = true;
                    };
                    keepDerivations = mkOption {
                      type = types.bool;
                      default = true;
                    };
                    downloadBufferSize = mkOption {
                      type = types.ints.positive;
                      default = 536870912;
                    };
                    httpConnections = mkOption {
                      type = types.ints.positive;
                      default = 128;
                    };
                  };
                };
              }
            )
          );
        };
      }
      { hosts = definitions; }
    ];
  };
  validate =
    name: host:
    let
      require = condition: message: lib.throwIfNot condition "Host ${name}: ${message}";
      darwin = host.format == "darwin";
      desktop = host.features.desktopEnvironment;
    in
    require (darwin == lib.hasSuffix "-darwin" host.system) "format and platform disagree" (
      require
        (
          if darwin then
            builtins.isInt host.stateVersion.system
          else
            builtins.isString host.stateVersion.system
        )
        "invalid system state version for format"
        (
          require
            (!host.enableAVF || (host.format == "nixos" && host.system == "aarch64-linux" && desktop == null))
            "AVF requires headless aarch64-linux"
            (
              require (desktop == null || desktop == (if darwin then "macos" else "niri"))
                "desktop environment does not match platform"
                (
                  require
                    (
                      desktop != null
                      || !(
                        host.features.desktopApps || host.features.animations || host.features.gaming || host.autologin
                      )
                    )
                    "desktop capabilities require a desktop environment"
                    (
                      require (host.appearances == [ ] || builtins.elem host.theme.appearance host.appearances)
                        "default appearance must be supported"
                        (require (lib.unique host.appearances == host.appearances) "appearances must be unique" host)
                    )
                )
            )
        )
    );
in
lib.mapAttrs validate evaluated.config.hosts
