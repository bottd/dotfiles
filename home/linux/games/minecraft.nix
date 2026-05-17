{ pkgs, ... }:
{
  home.packages = with pkgs; [
    (prismlauncher.override {
      jdks = [ temurin-bin-21 ];
    })
  ];

  # JAVA_HOME pins temurin for general use; prismlauncher carries its own jdks.
  # Not using `programs.java` because it adds temurin to home.packages, which
  # collides with the openjdk propagated by clojure/leiningen/babashka.
  home.sessionVariables = {
    JAVA_HOME = "${pkgs.temurin-bin-21}";
  };
}
