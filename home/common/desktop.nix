{ pkgs
, ...
}: {
  home.packages = with pkgs; [
    chromium
    firefox
    inkscape
  ];
}
