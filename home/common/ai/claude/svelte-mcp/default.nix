{ lib
, buildNpmPackage
, fetchurl
, jq
,
}:

buildNpmPackage rec {
  pname = "svelte-mcp";
  version = "0.1.25";

  src = fetchurl {
    url = "https://registry.npmjs.org/@sveltejs/mcp/-/mcp-${version}.tgz";
    hash = "sha256-DkdLjD6AmZR0b7ih5zQa7a84h9LxnFKO93nEPOTs058=";
  };

  nativeBuildInputs = [ jq ];

  # The committed lockfile is runtime-only, so devDependencies must go for
  # `npm ci` to consider package.json and the lock in sync.
  postPatch = ''
    cp ${./package-lock.json} package-lock.json
    jq 'del(.devDependencies)' package.json > package.json.tmp
    mv package.json.tmp package.json
  '';

  npmDepsHash = "sha256-fPhVgNEzHoL28As4ouJ3BKAR6Jmyp95IuZUDwFlG5ac=";

  dontNpmBuild = true;
  npmInstallFlags = [ "--ignore-scripts" ];

  # 26 MB of sourcemaps Node never reads without --enable-source-maps.
  postInstall = ''
    find $out -name '*.map' -delete
  '';

  meta = {
    description = "CLI version of the official Svelte MCP server";
    homepage = "https://github.com/sveltejs/ai-tools";
    license = lib.licenses.mit;
    mainProgram = "svelte-mcp";
    platforms = lib.platforms.linux ++ lib.platforms.darwin;
  };
}
