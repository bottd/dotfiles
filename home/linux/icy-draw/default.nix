{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, makeWrapper
, alsa-lib
, libxkbcommon
, libGL
, wayland
, libx11
, libxcursor
, libxi
, libxrandr
, libxcb
, openssl
, fontconfig
}:

# Not in nixpkgs and upstream ships no flake, so it's packaged here. IcyDraw is
# the only text-art editor that can author TheDraw .tdf fonts — which is the
# point: acid3dx.tdf has no '[' or ']' glyphs, so the brackets in the Mog
# wordmark are hand-painted into rendered output instead of living in the font.
rustPlatform.buildRustPackage rec {
  pname = "icy_draw";
  # A master revision, not the IcyDraw0.5.0 tag: that tag ships no Cargo.lock
  # (it's only committed on master), and buildRustPackage can't vendor without
  # one. Bump rev + hash together to update.
  version = "0.5.0-unstable-2026-07-17";

  src = fetchFromGitHub {
    owner = "mkrueger";
    repo = "icy_tools";
    rev = "47acdfaa4e3367ddf9335d261b9b58704a299946";
    # crates/icy_draw/external/plugins is a submodule
    fetchSubmodules = true;
    hash = "sha256-F3wzfM5U/QiMSdpajlymLaTBuRcmzYZrDMT6A5zDzfk=";
  };

  cargoHash = "sha256-nWgnTDu4IOJR57tsm8NbG9Ebd1Vu9Io3Z9F06rZvz04=";

  # the repo is a workspace of several tools; only IcyDraw is wanted
  cargoBuildFlags = [ "-p" "icy_draw" ];
  cargoTestFlags = cargoBuildFlags;
  # the suite wants a window server
  doCheck = false;

  nativeBuildInputs = [ pkg-config makeWrapper ];

  buildInputs = [
    alsa-lib
    openssl # openssl-sys, pulled in via the collaboration feature
    fontconfig
    libxkbcommon
    libGL
    wayland
    libx11
    libxcursor
    libxi
    libxrandr
    libxcb
  ];

  # Upstream ships a desktop entry and icon but no install rule, so without this
  # only the binary lands and nothing shows up in a launcher. Its Exec points at
  # /usr/bin, which doesn't exist here.
  postInstall = ''
    install -Dm644 crates/icy_draw/build/linux/icy_draw.desktop \
      $out/share/applications/icy_draw.desktop
    substituteInPlace $out/share/applications/icy_draw.desktop \
      --replace-fail /usr/bin/icy_draw $out/bin/icy_draw
    install -Dm644 crates/icy_draw/icon.png \
      $out/share/icons/hicolor/256x256/apps/icy_draw.png
  '';

  # eframe/winit dlopen these at runtime rather than linking them, so rpath
  # alone isn't enough — without this it builds fine and dies on launch.
  postFixup = ''
    wrapProgram $out/bin/icy_draw \
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [
        libGL libxkbcommon wayland libx11 libxcursor libxi libxrandr
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
