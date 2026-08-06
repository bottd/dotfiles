{ lib
, ...
}: {
  perSystem = { pkgs, ... }: {
    apps = lib.optionalAttrs pkgs.stdenv.isLinux {
      tresorit-install = {
        meta.description = "Seed ~/.local/share/tresorit from the pinned installer";
        program = lib.getExe (import ../scripts { inherit pkgs; }).tresorit-install;
      };
    };
  };
}
