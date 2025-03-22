{
  pkgs,
  config,
  inputs,
  ...
}: {
  # TODO: Install ghostty with nix
  # https://github.com/NixOS/nixpkgs/pull/368404
  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.meta.createSymlink "home/common/ghostty/config";
    };
  };

  home.packages = [
    inputs.ghostty.packages.${pkgs.stdenv.hostPlatform.system}.default
  ];
}
