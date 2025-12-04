{ ... }: {
  flake.overlays.default = final: prev: {
    gfn-electron = final.callPackage ../packages/gfn-electron { };
  };
}
