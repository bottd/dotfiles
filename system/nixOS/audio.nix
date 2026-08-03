{ pkgs, ... }:
let
  shurectl = pkgs.callPackage ./shurectl.nix { };
in
{
  security.rtkit.enable = true;

  # Run `shurectl` to reach the MV7+'s onboard DSP. The package ships the udev
  # rule that uaccess-tags the mic's hidraw node, so it works without root.
  environment.systemPackages = [ shurectl ];
  services.udev.packages = [ shurectl ];
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;

    extraConfig.pipewire-pulse."10-game-audio-sink" = {
      "pulse.cmd" = [
        {
          cmd = "load-module";
          args = "module-null-sink sink_name=game_audio_sink sink_properties=device.description=Game_Audio_Recording";
        }
      ];
    };
  };
}
