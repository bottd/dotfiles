{ inputs
, lib
, ...
}: {
  _module.args.lib = lib // {
    mkSystem = import ../lib/mkSystem.nix { inherit inputs; };
    mkHome = import ../lib/mkHome.nix { inherit inputs; };
    createSymlink = import ../lib/createSymlink.nix { inherit inputs; };
    utils = {
      isDarwin = system: builtins.elem system [
        "x86_64-darwin"
        "aarch64-darwin"
      ];
    };
  };
}
