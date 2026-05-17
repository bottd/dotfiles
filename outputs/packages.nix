{
  perSystem = { pkgs, lib, system, ... }: {
    packages = lib.optionalAttrs (lib.hasSuffix "linux" system) {
      xfce-winxp-tc = pkgs.callPackage ../pkgs/xfce-winxp-tc { };
    };
  };
}
