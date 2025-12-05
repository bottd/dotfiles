{ lib
, fetchFromGitHub
, makeWrapper
, electron
, buildNpmPackage
, makeDesktopItem
, copyDesktopItems
}:

buildNpmPackage rec {
  pname = "geforcenow-electron";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "hmlendea";
    repo = "gfn-electron";
    rev = "v${version}";
    hash = "sha256-DwrNCgBp0CD+HYXRMDsu0aKEKzG7k/tk7oATJc30DlE=";
  };

  npmDepsHash = "sha256-2v5qTTGhdG1EEK8v50LLYz5jE/36lBm1PKQl6HfqhCU=";
  forceGitDeps = true;
  makeCacheWritable = true;

  # Skip the electron download - we use the system electron
  env.ELECTRON_SKIP_BINARY_DOWNLOAD = "1";

  dontNpmBuild = true;

  nativeBuildInputs = [
    makeWrapper
    copyDesktopItems
  ];

  desktopItems = [
    (makeDesktopItem {
      name = "geforcenow-electron";
      desktopName = "GeForce NOW";
      exec = "geforcenow-electron";
      icon = "geforcenow-electron";
      comment = "GeForce NOW streaming client";
      categories = [ "Game" ];
    })
  ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/geforcenow-electron
    cp -r . $out/lib/geforcenow-electron

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/geforcenow-electron \
      --add-flags "$out/lib/geforcenow-electron"

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp icon.png $out/share/icons/hicolor/256x256/apps/geforcenow-electron.png

    runHook postInstall
  '';

  meta = with lib; {
    description = "Linux desktop client for GeForce NOW";
    homepage = "https://github.com/hmlendea/gfn-electron";
    license = licenses.gpl3Only;
    platforms = platforms.linux;
    mainProgram = "geforcenow-electron";
  };
}
