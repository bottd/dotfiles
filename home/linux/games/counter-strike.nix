_:
{
  home.file.".local/share/Steam/steamapps/common/Counter-Strike Global Offensive/game/csgo/cfg/autoexec.cfg".text = ''
    unbindall

    // Mouse Look
    m_yaw "0.022"
    m_pitch "0.022"
    cl_mouselook "1"
    bind "MOUSE_X" "yaw"
    bind "MOUSE_Y" "pitch"
    bind "MOUSE1" "+attack"
    bind "MOUSE2" "+attack2"
    bind "MOUSE3" "player_ping"    // Middle click = ping
    bind "MOUSE5" "+lookatweapon"  // Front side button = inspect

    // Movement
    bind "w" "+forward"
    bind "a" "+left"
    bind "s" "+back"
    bind "d" "+right"
    bind "SPACE" "+jump"
    bind "MWHEELDOWN" "+jump"
    bind "CTRL" "+duck"
    bind "SHIFT" "+sprint"

    // Weapon Actions
    bind "r" "+reload"
    bind "q" "drop"
    bind "e" "+use"

    // Weapon Slots
    bind "1" "slot1"
    bind "2" "slot2"
    bind "3" "slot3"
    bind "4" "slot4"
    bind "5" "slot5"

    // Comms
    bind "b" "buymenu"
    bind "TAB" "+showscores"
    bind "v" "+voicerecord"
    bind "`" "toggleconsole"
    bind "ESCAPE" "cancelselect"

    // Grenades
    bind "z" "slot10"  // Molotov/Incendiary
    bind "x" "slot9"   // Decoy
    bind "c" "slot8"   // Smoke
    bind "g" "slot6"   // HE Grenade
    bind "f" "slot7"   // Flashbang

    cl_radar_square_always "1"
    sensitivity "0.75"

    // Sound - mute all except MVP
    snd_deathcamera_volume "0"
    snd_menumusic_volume "0"
    snd_mvp_volume "1"
    snd_roundaction_volume "0"
    snd_roundend_volume "0"
    snd_roundstart_volume "0"
    snd_tensecondwarning_volume "0.5"
  '';
}
