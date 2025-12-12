{ pkgs, ... }: {
  home.packages = with pkgs; [
    notmuch
  ];
}
