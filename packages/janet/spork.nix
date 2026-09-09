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

  # treefmt's --fail-on-change also notices mtime-only rewrites.
  postPatch = ''
    substituteInPlace spork/fmt.janet \
      --replace-fail '(spit file out)' \
                     '(unless (= (string source) (string out)) (spit file out))'
  '';

  installPhase = ''
    runHook preInstall

    jpm --offline --tree=$out install

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    $out/bin/janet-format --help > /dev/null

    printf '(def x  1)\n' > format-fixture.janet
    printf '(def x 1)\n' > expected.janet
    $out/bin/janet-format -n -f format-fixture.janet
    cmp format-fixture.janet expected.janet
    touch -t 200001010000 format-fixture.janet
    touch -r format-fixture.janet expected.janet
    $out/bin/janet-format -n -f format-fixture.janet
    test ! format-fixture.janet -nt expected.janet
    cmp format-fixture.janet expected.janet

    runHook postInstallCheck
  '';

  meta = {
    description = "Official contrib library of various Janet utility modules";
    homepage = "https://github.com/janet-lang/spork";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
})
