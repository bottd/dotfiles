{ pkgs, ... }: {
  home.packages = with pkgs; [
    cargo-binstall
    (rustup.overrideAttrs (_oldAttrs: {
      doCheck = false;
    }))
  ];
}
