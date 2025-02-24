{
  home-manager,
  pkgs,
  ...
}: {
  home.packages = with pkgs; [
    steam
  ];
}
