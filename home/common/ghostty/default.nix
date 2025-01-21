{pkgs, config, ...}: {
  # TODO: Install ghostty with nix
  # https://github.com/NixOS/nixpkgs/pull/368404
  home.file = {
    ".config/ghostty/config" = {
      source = config.lib.meta.createSymlink("home/common/ghostty/config");
    };
  };

  # home.packages = with pkgs; [ 
    # ghostty
  # ];
}
