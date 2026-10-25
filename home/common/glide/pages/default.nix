{
  fetchPnpmDeps,
  lib,
  nodejs,
  pnpm,
  pnpmConfigHook,
  stdenvNoCC,
  # The Dither Press tokens (--press-*) Home Manager generates from Stylix.
  # Without them the committed src/palette.css (Everforest dark) is used.
  pressTokens ? null,
}:
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
    hash = "sha256-btVkxnQQdkQShyPtJNpU7PjmTQCe/xh0dY+0VHWmL/M=";
  };

  postPatch = lib.optionalString (pressTokens != null) ''
    cp ${pressTokens} src/palette.css
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
