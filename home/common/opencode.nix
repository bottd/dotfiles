{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.opencode.packages.${pkgs.system}.default
  ];
}
