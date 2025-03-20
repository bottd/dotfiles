{
  config,
  inputs,
  pkgs,
  ...
}: {
  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.meta.createSymlink "home/common/ghostty/config";
    };
  };
  home.packages = [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
