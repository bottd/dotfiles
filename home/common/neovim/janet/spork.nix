{ lib
, stdenv
, fetchFromGitHub
, janet
, jpm
}:

stdenv.mkDerivation (finalAttrs: {
  pname = "spork";
  version = "1.2.0";

  src = fetchFromGitHub {
    owner = "janet-lang";
    repo = "spork";
    rev = "v${finalAttrs.version}";
    hash = "sha256-aAM9USwh3ZifupHVPqu/aFyaLrTGlYnzV/88RDkpLjE=";
  };

  nativeBuildInputs = [ janet jpm ];
  buildInputs = [ janet ];

  dontConfigure = true;

  installPhase = ''
    runHook preInstall

    jpm --offline --tree=$out install

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/janet-format --help > /dev/null

    runHook postInstallCheck
  '';

  meta = {
    description = "Official contrib library of various Janet utility modules";
    homepage = "https://github.com/janet-lang/spork";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
