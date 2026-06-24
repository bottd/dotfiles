{ config, pkgs, ... }:
{
  home = {
    packages = [ pkgs.codex ];

    file = {
      ".codex/config.toml".source =
        config.lib.meta.createSymlink "home/common/codex/config.toml";
    };
  };
}
