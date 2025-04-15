{
  config,
  inputs,
  lib,
  pkgs,
  ...
}: {
  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.meta.createSymlink "home/common/ghostty/config";
    };
  };

  home.packages = lib.optionals pkgs.stdenv.isLinux [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
