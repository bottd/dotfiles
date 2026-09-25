{ pkgs, ... }:
{
  programs.obs-studio = {
    enable = true;
    plugins = [ pkgs.obs-studio-plugins.obs-advanced-masks ];
  };

  # Shadow OBS's desktop entry to run unscaled — the preview's click
  # hit-testing is offset under 125% fractional scaling, so force OBS
  # (only) to 1x. UI is a bit small; the cursor lines up.
  xdg.desktopEntries."com.obsproject.Studio" = {
    name = "OBS Studio";
    genericName = "Streaming/Recording Software";
    exec = "env QT_QPA_PLATFORM=xcb QT_AUTO_SCREEN_SCALE_FACTOR=0 QT_SCALE_FACTOR=1 obs";
    icon = "com.obsproject.Studio";
    terminal = false;
    categories = [ "AudioVideo" "Recorder" ];
    settings.StartupWMClass = "obs";
  };
}
