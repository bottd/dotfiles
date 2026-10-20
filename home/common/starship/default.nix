{ config, ... }: {
  stylix.targets.starship.enable = true;

  # Dither Press prompt: the directory is set as an ink slug whose edges break
  # up into halftone like the bar's top seam, the caret carries the accent
  # plate (paper text on base09 is only ~4:1 in the light variant, so the slug
  # stays ink), and the first line runs out to the clock on faint leader dots.
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = "[░▒▓](base07)$directory[▓▒░](base07) $git_branch$git_state$git_status$jobs$shell$fill $cmd_duration$time\n$character";

      character = {
        success_symbol = "[❯](bold base09)";
        error_symbol = "[❯](bold base08)";
      };

      directory = {
        truncation_length = 4;
        style = "bold fg:base00 bg:base07";
        read_only_style = "fg:base00 bg:base07";
        format = "[ $path ]($style)[$read_only]($read_only_style)";
      };

      fill = {
        symbol = "·";
        style = "base02";
      };

      time = {
        disabled = false;
        style = "base04";
        format = "[$time]($style)";
        time_format = "%a, %b %e at %I:%M";
      };

      git_branch = {
        style = "bold base07";
        format = "[$branch]($style) ";
      };

      git_status = {
        format = "[$staged](#${config.lib.stylix.colors.base0B})[$modified](base08)";
        staged = "+\${count} ";
        modified = "~\${count} ";
      };

      cmd_duration.format = "[took $duration](#${config.lib.stylix.colors.base0A}) ";
    };
  };
}
