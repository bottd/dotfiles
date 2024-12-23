{pkgs, config, lib, inputs, ...}: {
  lib.meta = {
    createSymLink = path: lib.file.mkOutOfStoreSymlink (
    "${config.home.homeDirectory}/workspace/dotfiles/${path}"
  };
}
