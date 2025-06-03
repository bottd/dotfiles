{ ...
}: {
  home.file = {
    ".config/eww" = {
      source = config.lib.meta.createSymlink "home/linux/eww";
      recursive = true;
    };
  };
}
