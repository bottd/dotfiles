{ lib, stdenvNoCC, fetchFromGitHub, janet, jpm }:

stdenvNoCC.mkDerivation {
  pname = "janet-cmd";
  version = "0-unstable-2025-05-06";

  src = fetchFromGitHub {
    owner = "CFiggers";
    repo = "cmd";
    rev = "b0a34d6e854578bd672d43303e80b9777af08b42";
    hash = "sha256-Kkwde3hHgbi8aj9ud6rOh13KWVxdNCNY4zXnDVj7uzA=";
  };

  nativeBuildInputs = [ janet jpm ];
  dontConfigure = true;
  dontBuild = true;
  dontGzipMan = true;

  # The fork qualified its imports but left this export pointing at core/parse.
  postPatch = ''
    substituteInPlace src/init.janet \
      --replace-fail '(def parse parse)' '(def parse arg-parser/parse)'
  '';

  installPhase = ''
    runHook preInstall
    jpm --offline --tree=$out install
    # cmd's macros need initialized parser tables even during Janet flycheck.
    janet -R -c $out/lib/cmd/init.janet $out/lib/cmd.jimage
    runHook postInstall
  '';

  meta = {
    description = "Declarative command-line argument parser for Janet";
    homepage = "https://github.com/CFiggers/cmd";
    license = lib.licenses.mit;
    platforms = lib.platforms.unix;
  };
}
