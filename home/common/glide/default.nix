{ config, inputs, ... }: {
  imports = [ inputs.glide.homeModules.default ];

  programs.glide-browser = {
    enable = true;
  };

  home.file.".config/glide" = {
    source = config.lib.meta.createSymlink "home/common/glide/config";
  };
}
