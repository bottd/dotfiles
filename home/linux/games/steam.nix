{ pkgs, ... }:
{
  home.packages = with pkgs; [
    chiaki-ng
    gamescope
  ];

  stylix.targets.mangohud.enable = true;

  programs.mangohud = {
    enable = true;
    enableSessionWide = false;
    settings = {
      legacy_layout = false;
      gpu_stats = true;
      gpu_temp = true;
      gpu_mem_temp = false;
      gpu_load_change = false;
      gpu_load_value = "50,90";
      gpu_text = "GPU";
      cpu_stats = true;
      cpu_temp = true;
      cpu_load_change = false;
      core_load_change = false;
      cpu_load_value = "50,90";
      cpu_text = "CPU";
      vram = false;
      ram = false;
      fps = true;
      frame_timing = 1;
      position = "top-left";
      round_corners = 10;
      toggle_hud = "Shift_R+F12";
      toggle_fps_limit = "Shift_L+F1";
    };
  };
}
