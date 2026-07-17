{ fetchPnpmDeps
, lib
, nodejs
, pnpm
, pnpmConfigHook
, stdenvNoCC
, stylixPalette ? builtins.fromJSON (builtins.readFile ./stylix-palette.json)
, writeText
}:
let
  colorNames = [
    "base00"
    "base01"
    "base02"
    "base03"
    "base04"
    "base05"
    "base06"
    "base07"
    "base08"
    "base09"
    "base0A"
    "base0B"
    "base0C"
    "base0D"
    "base0E"
    "base0F"
  ];
  palette = lib.genAttrs colorNames (
    name:
    let
      value = stylixPalette.${name};
    in
    if lib.hasPrefix "#" value then value else "#${value}"
  );
  paletteFile = writeText "stylix-palette.json" (builtins.toJSON palette);
in
stdenvNoCC.mkDerivation (finalAttrs: {
  pname = "glide-pages";
  version = "0.1.0";

  src = lib.fileset.toSource {
    root = ./.;
    fileset = lib.fileset.unions [
      ./.npmrc
      ./index.html
      ./package.json
      ./pnpm-lock.yaml
      ./src
      ./tsconfig.json
      ./uno.config.ts
      ./vite.config.ts
    ];
  };

  nativeBuildInputs = [
    nodejs
    pnpm
    pnpmConfigHook
  ];

  pnpmDeps = fetchPnpmDeps {
    inherit (finalAttrs) pname version src;
    inherit pnpm;
    fetcherVersion = 4;
    hash = "sha256-EAIlg5Fiu1TLWeK2iDViJiA7sACFVa8gL7nwUPBY0Ns=";
  };

  postPatch = ''
    cp ${paletteFile} stylix-palette.json
  '';

  buildPhase = ''
    runHook preBuild
    pnpm build
    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall
    cp -r dist/. $out
    runHook postInstall
  '';
})
