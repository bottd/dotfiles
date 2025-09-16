_:

{
  services.jellyfin = {
    enable = true;
    openFirewall = true;
  };

  # Add jellyfin to the audio group for hardware acceleration (optional)
  users.users.jellyfin = {
    extraGroups = [ "audio" "video" "render" ];
  };
}
