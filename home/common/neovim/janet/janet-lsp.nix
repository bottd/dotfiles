{ lib
, stdenv
, fetchFromGitHub
, git
, janet
, jpm
, spork
}:

let
  cmd = fetchFromGitHub {
    owner = "CFiggers";
    repo = "cmd";
    rev = "b0a34d6e854578bd672d43303e80b9777af08b42";
    hash = "sha256-Kkwde3hHgbi8aj9ud6rOh13KWVxdNCNY4zXnDVj7uzA=";
  };

  judge = fetchFromGitHub {
    owner = "CFiggers";
    repo = "judge";
    rev = "1d329cb3a7384c3ff0f6232e60d81aa9db3a5440";
    hash = "sha256-iR7bCEVvJK3lF9m4hXJhQ4JRnhvcGjgBrWuWIiYT7dg=";
  };
in

stdenv.mkDerivation (finalAttrs: {
  pname = "janet-lsp";
  version = "0.0.13";

  src = fetchFromGitHub {
    owner = "CFiggers";
    repo = "janet-lsp";
    rev = "v${finalAttrs.version}";
    hash = "sha256-lJzTQmjQyyWq+HYEInJuPdcxUwz+KybI5jl0pj9jtIs=";
  };

  nativeBuildInputs = [ janet jpm ];
  buildInputs = [ janet ];

  dontConfigure = true;

  postPatch = ''
    substituteInPlace libs/jayson.janet \
      --replace-fail '(some (+ :0to31 :backslash :quote :one-byte :multi-byte))' \
                     '(any (+ :0to31 :backslash :quote :one-byte :multi-byte))'

    substituteInPlace src/main.janet \
      --replace-fail '["git" "rev-parse" "--short" "HEAD"] :xp' \
                     '["${lib.getExe' git "git"}" "rev-parse" "--short" "HEAD"] :p'

    sed -i '1i #!${lib.getExe' janet "janet"}' src/janet-lsp
  '';

  installPhase = ''
    runHook preInstall

    tree=$out/share/janet-lsp

    mkdir -p "$tree/lib"
    cp -R --no-preserve=mode,ownership ${spork}/lib/. "$tree/lib/"

    for dep in ${cmd} ${judge}; do
      cp -R --no-preserve=mode,ownership "$dep" ./jpm-dep
      (cd ./jpm-dep && jpm --offline --tree="$tree" install)
      rm -rf ./jpm-dep
    done

    jpm --offline --tree="$tree" install

    mkdir -p $out/bin
    mv "$tree/bin/janet-lsp" $out/bin/janet-lsp
    rm -rf "$tree/bin" "$tree/man"

    runHook postInstall
  '';

  doInstallCheck = true;

  installCheckPhase = ''
    runHook preInstallCheck

    (cd / && $out/bin/janet-lsp --version)

    init='{"jsonrpc":"2.0","id":1,"method":"initialize","params":{"processId":null,"rootUri":null,"capabilities":{}}}'
    printf 'Content-Length: %d\r\n\r\n%s' "''${#init}" "$init" \
      | timeout 120 $out/bin/janet-lsp --stdio > handshake.json || true
    grep -q '"capabilities"' handshake.json

    runHook postInstallCheck
  '';

  meta = {
    description = "Language Server Protocol implementation for the Janet programming language";
    homepage = "https://github.com/CFiggers/janet-lsp";
    license = lib.licenses.mit;
    mainProgram = "janet-lsp";
    platforms = lib.platforms.unix;
  };
})
