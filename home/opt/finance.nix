{ pkgs, ... }: {
  home.packages = with pkgs; [
    hledger
    hledger-web
    puffin
  ];
}
