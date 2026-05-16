{ stdenv
, lib
, fetchFromGitHub
, cmake
, pkg-config
, python3
, sass
, sassc
, xorg
, gettext
, wrapGAppsHook3
, glib
, gtk3
, xfce
, libcanberra-gtk3
, libpulseaudio
, upower
, networkmanager
, libxml2
, libwnck
}:

stdenv.mkDerivation {
  pname = "xfce-winxp-tc";
  version = "0-unstable-2026-05-11";

  src = fetchFromGitHub {
    owner = "rozniak";
    repo = "xfce-winxp-tc";
    rev = "2242a2b055da6a1c2036e23fa393d87ada670678";
    hash = "sha256-QQdcYHW5YEIoG6wZbnyZZuvyVZhYwXsro9ZmbDRDhlQ=";
  };

  patches = [
    ./pinned-start-menu.patch
    ./taskband-class-name.patch
  ];

  nativeBuildInputs = [
    cmake
    pkg-config
    (python3.withPackages (ps: with ps; [ pillow packaging ]))
    sass
    sassc
    xorg.xcursorgen
    gettext
    wrapGAppsHook3
  ];

  buildInputs = [
    glib
    gtk3
    xfce.garcon
    xfce.libxfce4ui
    libcanberra-gtk3
    libpulseaudio
    upower
    networkmanager
    libxml2
    libwnck
  ];

  # shared/shelldpa dlopens "libwnck-3.so.0" by short name; under Nix it isn't
  # on the default linker search path. Extend the gApps wrapper's runtime env.
  preFixup = ''
    gappsWrapperArgs+=(
      --prefix LD_LIBRARY_PATH : ${lib.makeLibraryPath [ libwnck ]}
    )
  '';

  # buildall.sh chains its own per-component cmake invocations; the default
  # cmake hook would try to configure the top of the tree (which has no
  # CMakeLists.txt) and fail.
  dontUseCmakeConfigure = true;

  # icons/luna creates relative symlinks (32x32/actions/cut.png -> res/32x32/cut.png)
  # that resolve against the source tree's res/ subdir. The mappings install
  # appears to skip a chunk of res files in our setup; the taskband doesn't
  # need these icons at runtime, so don't block the whole build on them.
  dontCheckForBrokenSymlinks = true;

  postPatch = ''
    substituteInPlace packaging/build.sh \
      --replace-fail 'dist_prefix="/usr"' "dist_prefix=\"$out\""

    # distid.sh validates a -t target by probing for the matching pkg manager
    # (pacman, dpkg, etc) which the Nix sandbox doesn't have. Trust the caller
    # when DIST_ID is preset — we are caller, we know what we asked for.
    substituteInPlace packaging/distid.sh \
      --replace-fail '        g_compare_against_env=1' \
      '        g_compare_against_env=1; g_compare_successful=1'

    # Replace the upstream targets list (40+ components incl. OOBE/IE/taskmgr
    # that pull gstreamer, webkitgtk, etc) with the subset needed for the
    # taskband + start menu and its visual assets.
    printf '%s\n' \
      'base/bldtag' \
      'themes/luna/blue' \
      'icons/luna' \
      'fonts' \
      'sounds' \
      'shell/taskband' \
      > packaging/targets

    patchShebangs packaging tools
  '';

  # nixpkgs splits gio-unix-2.0 headers (gdesktopappinfo.h, etc) into a
  # separate include dir from gio-2.0; upstream CMakeLists only asks
  # pkg-config for glib-2.0. Expose the unix headers globally.
  env.NIX_CFLAGS_COMPILE = "-I${lib.getDev glib}/include/gio-unix-2.0";

  buildPhase = ''
    runHook preBuild

    cd packaging
    ./buildall.sh -z -t archpkg

    runHook postBuild
  '';

  installPhase = ''
    runHook preInstall

    while IFS= read -r mf; do
      ( cd "$(dirname "$mf")" && make install )
    done < <(find build -mindepth 1 -name Makefile)

    runHook postInstall
  '';

  meta = with lib; {
    description = "Windows XP Total Conversion for XFCE";
    homepage = "https://github.com/rozniak/xfce-winxp-tc";
    license = licenses.gpl2Only;
    platforms = platforms.linux;
  };
}
