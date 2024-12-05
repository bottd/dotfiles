{pkgs, ...}: {
  home.file.".config/starship" = {
    source = ../starship;
  };

  programs.starship = { 
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };
}
