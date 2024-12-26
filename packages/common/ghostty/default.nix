{pkgs, ...}: {
  # TODO: Install ghostty with nix
  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.meta.createSymlink("packages/common/ghostty/config");
    };
  }
}
