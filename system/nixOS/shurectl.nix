{ lib
, rustPlatform
, fetchFromGitHub
, pkg-config
, alsa-lib
, udev
}:

# Not in nixpkgs. Replaces the ShurePlus MOTIV desktop app, which is Windows/Mac
# only — without this the MV7+'s onboard DSP (denoiser, popper stopper,
# compressor, high-pass, auto-vs-manual gain) is unreachable on Linux, since ALSA
# exposes nothing but mic gain and a mute switch.
rustPlatform.buildRustPackage rec {
  pname = "shurectl";
  version = "2.5.0";

  src = fetchFromGitHub {
    owner = "Humblemonk";
    repo = "shurectl";
    rev = "v${version}";
    hash = "sha256-KrIOKoO2chkM/bAu/fzc+fP2o8CZZPUi4dJRBZ0z9MY=";
  };

  cargoHash = "sha256-r1feJ78eRgLx3PyVEbluQ9gTuYKsq2j2f+EVCOIXIi0=";

  # alsa-lib for cpal (the input level meter); udev because hidapi's
  # linux-native backend still enumerates devices through libudev-sys.
  nativeBuildInputs = [ pkg-config ];
  buildInputs = [ alsa-lib udev ];

  # src/bin/probe.rs is a HID feature-address sweeper for reverse-engineering
  # work. Building it too would put a binary named `probe` on the system PATH.
  cargoBuildFlags = [ "--bin" "shurectl" ];

  # Upstream ships the rules file but has no install rule for it. Carrying it in
  # the package lets services.udev.packages pick it up, so the vendor/product IDs
  # live in one place instead of being copied into a NixOS module.
  postInstall = ''
    install -Dm644 62-shure.rules $out/lib/udev/rules.d/62-shure.rules
  '';

  meta = {
    description = "TUI configurator for Shure USB microphones and audio interfaces";
    homepage = "https://github.com/Humblemonk/shurectl";
    license = lib.licenses.gpl3Only;
    mainProgram = "shurectl";
    platforms = lib.platforms.linux;
  };
}
