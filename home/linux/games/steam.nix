{ config, pkgs, ... }:
{
  home.packages = with pkgs; [
    chiaki-ng
    gamescope
  ];

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
      gpu_load_color = "FFFFFF,${config.colorScheme.palette.base09},${config.colorScheme.palette.base08}";
      gpu_text = "GPU";
      cpu_stats = true;
      cpu_temp = true;
      cpu_load_change = false;
      core_load_change = false;
      cpu_load_value = "50,90";
      cpu_load_color = "FFFFFF,${config.colorScheme.palette.base09},${config.colorScheme.palette.base08}";
      cpu_color = config.colorScheme.palette.base05;
      cpu_text = "CPU";
      io_color = config.colorScheme.palette.base0B;
      vram = false;
      ram = false;
      fps = true;
      engine_color = config.colorScheme.palette.base0E;
      gpu_color = config.colorScheme.palette.base0B;
      wine_color = config.colorScheme.palette.base0E;
      frame_timing = 1;
      frametime_color = config.colorScheme.palette.base0B;
      media_player_color = config.colorScheme.palette.base0A;
      background_alpha = "0.8";
      font_size = 24;

      background_color = config.colorScheme.palette.base00;
      position = "top-left";
      text_color = config.colorScheme.palette.base05;
      round_corners = 10;
      toggle_hud = "Shift_R+F12";
      toggle_fps_limit = "Shift_L+F1";
    };
  };
}
