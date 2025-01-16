{pkgs, ...}: {
  home.file.".config/nushell" = {
    source = ../nushell;
  };

  programs.nushell.enable = true;
}
