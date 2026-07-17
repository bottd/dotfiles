{ lib, stdenv, fetchFromGitHub, qt6, colors }:
let
  rgb = hex:
    lib.concatStringsSep "," (map
      (offset: toString (lib.fromHexString (builtins.substring offset 2 hex)))
      [ 0 2 4 ]);

  colorSection = name: color: ''
    [${name}]
    Bold=false
    Color=${rgb color}
  '';
in
stdenv.mkDerivation {
  pname = "qmltermwidget";
  version = "2.0.0-unstable-2026-05-31";

  src = fetchFromGitHub {
    owner = "Swordfish90";
    repo = "qmltermwidget";
    rev = "8913504fa2ebd220ebe7c680c32954e1b3c035c5";
    hash = "sha256-Tm4ABLH4dquCNyee8vrlWN5S5ehtZBFU2rseW6IA/dw=";
  };

  patches = [ ./qmltermwidget-resize.patch ];

  nativeBuildInputs = [ qt6.qmake ];
  buildInputs = [ qt6.qtbase qt6.qtdeclarative ];
  dontWrapQtApps = true;

  installPhase = ''
    runHook preInstall

    moduleDir="$out/${qt6.qtbase.qtQmlPrefix}/QMLTermWidget"
    mkdir -p "$moduleDir"
    cp -R QMLTermWidget/. "$moduleDir/"

    cat > "$moduleDir/color-schemes/Stylix.colorscheme" <<'EOF'
    ${colorSection "Background" colors.base00}
    ${colorSection "BackgroundIntense" colors.base01}
    ${colorSection "Color0" colors.base00}
    ${colorSection "Color0Intense" colors.base03}
    ${colorSection "Color1" colors.base08}
    ${colorSection "Color1Intense" colors.base08}
    ${colorSection "Color2" colors.base0B}
    ${colorSection "Color2Intense" colors.base0B}
    ${colorSection "Color3" colors.base0A}
    ${colorSection "Color3Intense" colors.base0A}
    ${colorSection "Color4" colors.base0D}
    ${colorSection "Color4Intense" colors.base0D}
    ${colorSection "Color5" colors.base0E}
    ${colorSection "Color5Intense" colors.base0E}
    ${colorSection "Color6" colors.base0C}
    ${colorSection "Color6Intense" colors.base0C}
    ${colorSection "Color7" colors.base05}
    ${colorSection "Color7Intense" colors.base07}
    ${colorSection "Foreground" colors.base07}
    ${colorSection "ForegroundIntense" colors.base07}
    [General]
    Description=Stylix
    EOF

    runHook postInstall
  '';

  meta = {
    description = "Terminal emulator plugin for QML";
    homepage = "https://github.com/Swordfish90/qmltermwidget";
    license = lib.licenses.gpl2Plus;
    platforms = lib.platforms.unix;
  };
}
