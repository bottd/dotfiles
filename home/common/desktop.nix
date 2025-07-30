{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    firefox
    inkscape
  ];
}
