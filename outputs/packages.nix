_: {
  perSystem = { pkgs, ... }: {
    packages.seo = pkgs.callPackage ../home/common/ai/seo/package.nix { };
  };
}
