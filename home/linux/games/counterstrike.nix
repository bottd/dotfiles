_:
{
  programs.steam.config.apps.counterstrike2 = {
    id = 730;
    compatTool = "GE-Proton";
    autoexec = ''
      cl_radar_square_always "1"
      sensitivity "0.75"
      bind "g" "slot7"
      bind "f" "slot6"
      bind "x" "slot8"
      bind "z" "slot9"
    '';
  };
}
