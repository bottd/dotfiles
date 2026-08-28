{ lib
, stdenvNoCC
, importNpmLock
, makeWrapper
, nodejs_22
, nodejs-slim_22
}:
let
  npmRoot = ./npm;

  # The pin lives in npm/package.json so `npm install --package-lock-only`
  # stays the only step needed to bump the release.
  version = (lib.importJSON (npmRoot + "/package.json")).dependencies.seo;

  nodeModules = importNpmLock.buildNodeModules {
    inherit npmRoot;
    nodejs = nodejs_22;
    derivationArgs = {
      pname = "seo-node-modules";
      inherit version;

      # The lock is generated with --legacy-peer-deps (the only auto-installed
      # peer is typescript, which pulls ~20 platform binaries the CLI never
      # loads); npm install has to agree or it goes looking for them online.
      npmInstallFlags = [ "--legacy-peer-deps" ];

      # npm rewrites every `resolved` in .package-lock.json to a store path, so
      # keeping the file pins all 240 source tarballs as runtime references.
      # Sourcemaps and type declarations are dead weight too: the wrapper never
      # passes --enable-source-maps, and nothing type-checks against the store.
      postInstall = ''
        rm -f $out/node_modules/.package-lock.json
        find $out/node_modules \( -name '*.map' -o -name '*.d.ts' \) -delete
      '';
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

    # nodejs-slim drops npm and corepack; the CLI resolves npm from PATH when it
    # installs an optional research provider, never from its own interpreter.
    makeWrapper ${lib.getExe nodejs-slim_22} $out/bin/seo \
      --add-flags ${seoModule}/dist/cli.js \
      --set-default NO_UPDATE_NOTIFIER 1

    # Skills are copied rather than symlinked: home-manager links them into
    # ~/.claude/skills, and agents that walk the tree should not have to
    # resolve back through node_modules.
    mkdir -p $out/share/seo
    cp -R ${seoModule}/skills $out/share/seo/skills

    runHook postInstall
  '';

  meta = {
    description = "SEO audits, search opportunities, and competitor research as a local CLI and MCP server";
    homepage = "https://github.com/iannuttall/seo";
    license = lib.licenses.asl20;
    mainProgram = "seo";
    platforms = lib.platforms.unix;
  };
}
