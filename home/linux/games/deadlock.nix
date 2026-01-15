_:
{
  programs.steam.config.apps.deadlock = {
    id = 1422450;
    compatTool = "GE-Proton";
    launchOptions = ''LD_PRELOAD="" gamemoderun %command% -no_prewarm_map'';
  };
}
