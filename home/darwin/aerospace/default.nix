{pkgs, ...}: {
  home.file.".aerospace.toml" = {
    source = inputs.config.lib.meta.createSymlink "home/darwin/aerospace/aerospace.toml";
  };

  home.packages = with pkgs; [
    aerospace
  ];
}
