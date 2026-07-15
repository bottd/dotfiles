{ config, pkgs, ... }:
{
  home = {
    packages = [ pkgs.pi-coding-agent ];

    file = {
      # Mutable symlink so `/settings` and `pi config` edits land back in
      # this repo (git-tracked). Sessions/auth stay in ~/.pi/agent/.
      ".pi/agent/settings.json".source =
        config.lib.meta.createSymlink "home/common/pi/settings.json";
    };
  };

  programs.git.ignores = [ ".pi/settings.json" ];
}
