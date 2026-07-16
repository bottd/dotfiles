{ config, inputs, ... }:
{
  imports = [ inputs.kli.homeManagerModules.default ];

  programs.kli.enable = true;

  home.file = {
    ".config/kli/settings.json".source =
      config.lib.meta.createSymlink "home/common/ai/kli/settings.json";
  };
}
