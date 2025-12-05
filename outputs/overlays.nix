_: {
  flake.overlays.default = final: _prev: {
    gfn-electron = final.callPackage ../packages/gfn-electron { };
  };
}
