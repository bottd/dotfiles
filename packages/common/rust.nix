{pkgs, ...}: {
  home.packages = with pkgs; [
    cargo
    clippy
    gcc
    rustc
    rustfmt
  ];
}
