{ config
, ...
}: {
  home.file.".aerospace.toml" = {
    source = config.lib.meta.createSymlink "home/darwin/aerospace/aerospace.toml";
  };
}
