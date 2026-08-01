{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, alsa-lib
, libxkbcommon
, libGL
, wayland
, xorg
}:

# Not in nixpkgs and upstream ships no flake, so it's packaged here. IcyDraw is
# the only text-art editor that can author TheDraw .tdf fonts — which is the
# point: acid3dx.tdf has no '[' or ']' glyphs, so the brackets in the Mog
# wordmark are hand-painted into rendered output instead of living in the font.
rustPlatform.buildRustPackage rec {
  pname = "icy_draw";
  version = "0.5.0";

  src = fetchFromGitHub {
    owner = "mkrueger";
    repo = "icy_tools";
    rev = "IcyDraw${version}";
    # crates/icy_draw/external/plugins is a submodule
    fetchSubmodules = true;
    hash = "sha256-ma6dW/KVZXfPZmRpKOEIE2F8ziGB72NoLheGzUuNiCs=";
  };

  cargoHash = lib.fakeHash;

  # the repo is a workspace of several tools; only IcyDraw is wanted
  cargoBuildFlags = [ "-p" "icy_draw" ];
  cargoTestFlags = cargoBuildFlags;
  # the suite wants a window server
  doCheck = false;

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [
    alsa-lib
    libxkbcommon
    libGL
    wayland
    xorg.libX11
    xorg.libXcursor
    xorg.libXi
    xorg.libXrandr
    xorg.libxcb
  ];

  # eframe/winit dlopen these at runtime rather than linking them, so rpath
  # alone isn't enough — without this it builds fine and dies on launch.
  postFixup = ''
    wrapProgram $out/bin/icy_draw \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libGL libxkbcommon wayland xorg.libX11 xorg.libXcursor xorg.libXi xorg.libXrandr
      ]}
  '';

  meta = {
    description = "Text-art editor for ANSI/ASCII with a TheDraw (.tdf) font editor";
    homepage = "https://github.com/mkrueger/icy_tools";
    license = with lib.licenses; [ asl20 mit ];
    mainProgram = "icy_draw";
    platforms = lib.platforms.linux;
  };
}
