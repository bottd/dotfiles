{ fetchurl, writers }:
let
  # Pinned so the initial install seed is reproducible. The proprietary client
  # self-updates afterwards, so this only fixes what lands on first run.
  installer = fetchurl {
    name = "tresorit-installer-3.5.1281.4700.run";
    url = "https://installer.tresorit.com/tresorit_installer.run";
    hash = "sha256-6PGp83mFSJSlBmycKyIYS+kU9lZpVWZ8FZccukdjyUM=";
  };
in
writers.writeBabashkaBin "tresorit-install" { }
  (builtins.replaceStrings
    [ "@tresorit-installer@" ]
    [ "${installer}" ]
    (builtins.readFile ./tresorit-install.clj))
