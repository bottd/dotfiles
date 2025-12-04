{ lib
, stdenv
, fetchFromGitHub
, makeWrapper
, electron
, nodejs
, pnpm_9
, makeDesktopItem
, copyDesktopItems
}:

stdenv.mkDerivation rec {
  pname = "geforcenow-electron";
  version = "2.2.0";

  src = fetchFromGitHub {
    owner = "hmlendea";
    repo = "gfn-electron";
    rev = "v${version}";
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  pnpmDeps = pnpm_9.fetchDeps {
    inherit pname version src;
    hash = "sha256-AAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAAA=";
  };

  nativeBuildInputs = [
    nodejs
    pnpm_9.configHook
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

  buildPhase = ''
    runHook preBuild
    pnpm install --offline
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    mkdir -p $out/lib/geforcenow-electron
    cp -r . $out/lib/geforcenow-electron

    mkdir -p $out/bin
    makeWrapper ${electron}/bin/electron $out/bin/geforcenow-electron \
      --add-flags "$out/lib/geforcenow-electron"

    mkdir -p $out/share/icons/hicolor/256x256/apps
    cp assets/icon.png $out/share/icons/hicolor/256x256/apps/geforcenow-electron.png

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
