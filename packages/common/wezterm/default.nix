{pkgs, ...}: {
  programs.wezterm.enable = true;

  # Source wezterm config
  xdg.configFile.wezterm = {
    source = ../wezterm;
    recursive = true;
  };
}
