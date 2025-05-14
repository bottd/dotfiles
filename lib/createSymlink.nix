{
  config,
  lib,
  ...
}: {
  lib.meta = {
    createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
  };
}
