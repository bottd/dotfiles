
{pkgs, ...}: {
  home.file.".aerospace.toml" = {
    source = ./aerospace.toml;
  };

  home.packages = with pkgs; [ 
    aerospace
  ];
}
