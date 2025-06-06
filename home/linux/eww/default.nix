{ ...
}: {
  programs.eww = {
    enable = true;
    configDir = ./eww-bar;
  };
}
