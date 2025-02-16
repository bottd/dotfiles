{
  pkgs,
  config,
  lib,
  inputs,
  ...
}: {
  lib.meta = {
    createSymlink = path: config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";
  };
}
