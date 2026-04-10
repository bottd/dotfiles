_:
{
  stylix.targets.starship.enable = true;

  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = "$time[ on ](base05)$git_branch$git_state$jobs$shell$fill [$git_status](base04)\n $directory$character";
      right_format = "$cmd_duration";

      character = {
        success_symbol = "[❯](bold base0E)";
        error_symbol = "[❯](bold base08)";
      };

      directory = {
        truncation_length = 4;
        style = "bold base0E";
      };

      fill.symbol = " ";

      time = {
        disabled = false;
        style = "bold italic base0D";
        format = "[$time]($style)";
        time_format = "%a, %b %e at %I:%M";
      };

      git_status = {
        style = "base04";
        format = "[$staged](base0C)[$modified](base08) ";
        staged = " \${count} staged";
        modified = " \${count} modified";
      };

      git_branch = {
        style = "base08";
        format = " [$symbol$branch]($style)";
      };

      cmd_duration.format = "[took $duration](base0A)";
    };
  };
}
