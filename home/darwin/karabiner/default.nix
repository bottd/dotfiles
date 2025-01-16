{pkgs, ...}: {
  home.file.".config/karabiner/karabiner.json" = {
    source = ./karabiner.json;
  };
  # TODO: install karabiner? Seems only available as a darwin service:
  #services.karabiner-elements.enable = true;
}
