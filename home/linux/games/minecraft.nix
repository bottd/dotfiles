{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [ temurin-bin-21 ];
    })
  ];

  home.sessionVariables = {
    JAVA_HOME = "${pkgs.temurin-bin-21}";
  };

  programs.java = {
    enable = true;
    package = pkgs.temurin-bin-21;
  };
}
