_: {
  # Exposed so other flakes can reuse this packaging instead of repeating it.
  flake.overlays.default = final: _prev: {
    seo = final.callPackage ../home/common/ai/seo/package.nix { };
  };

  perSystem = { pkgs, ... }: {
    packages.seo = pkgs.callPackage ../home/common/ai/seo/package.nix { };
  };
}
