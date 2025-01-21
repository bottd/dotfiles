
{pkgs, config, ...}: {
  home.file.".aerospace.toml" = {
    source = config.lib.meta.createSymlink("home/darwin/aerospace/aerospace.toml");
  };

  home.packages = with pkgs; [ 
    aerospace
  ];
}
