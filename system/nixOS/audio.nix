{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    jack.enable = true;
    wireplumber.enable = true;

    extraConfig.pipewire."92-game-audio-sink" = {
      "context.objects" = [
        {
          factory = "adapter";
          args = {
            "factory.name" = "support.null-audio-sink";
            "node.name" = "GameAudio";
            "node.description" = "Game Audio (Recording)";
            "media.class" = "Audio/Sink";
            "audio.position" = [ "FL" "FR" ];
          };
        }
      ];
    };
  };
}
