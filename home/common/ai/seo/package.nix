{ lib
, stdenvNoCC
, importNpmLock
, makeWrapper
, nodejs_22
}:
let
  nodejs = nodejs_22;

  npmRoot = ./npm;

  # The pin lives in npm/package.json so `npm install --package-lock-only`
  # stays the only step needed to bump the release.
  version = (lib.importJSON (npmRoot + "/package.json")).dependencies.seo;

  nodeModules = importNpmLock.buildNodeModules {
    inherit npmRoot nodejs;
    derivationArgs = {
      pname = "seo-node-modules";
      inherit version;
      # The lock is generated with --legacy-peer-deps (the only auto-installed
      # peer is typescript, which pulls ~20 platform binaries the CLI never
      # loads); npm install has to agree or it goes looking for them online.
      npmInstallFlags = [ "--legacy-peer-deps" ];
    };
  };

  seoModule = "${nodeModules}/node_modules/seo";
in
stdenvNoCC.mkDerivation {
  pname = "seo";
  inherit version;

  dontUnpack = true;

  nativeBuildInputs = [ makeWrapper ];

  installPhase = ''
    runHook preInstall

    mkdir -p $out/bin
    makeWrapper ${lib.getExe nodejs} $out/bin/seo \
      --add-flags ${seoModule}/dist/cli.js \
      --set-default NO_UPDATE_NOTIFIER 1

    # Skills are copied rather than symlinked: home-manager links them into
    # ~/.claude/skills, and agents that walk the tree should not have to
    # resolve back through node_modules.
    mkdir -p $out/share/seo
    cp -R ${seoModule}/skills $out/share/seo/skills
    chmod -R u+w $out/share/seo

    runHook postInstall
  '';

  passthru = {
    inherit nodejs nodeModules;
    skills = "share/seo/skills";
  };

  meta = {
    description = "SEO audits, search opportunities, and competitor research as a local CLI and MCP server";
    homepage = "https://github.com/iannuttall/seo";
    license = lib.licenses.asl20;
    mainProgram = "seo";
    platforms = lib.platforms.darwin ++ lib.platforms.linux;
  };
}
