_:
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
    settings = {
      format = "$time[ on ]$git_branch$git_state$jobs$shell$fill [$git_status]\n $directory$character";
      right_format = "$cmd_duration";

      directory = {
        truncation_length = 4;
        style = "bold";
      };

      fill.symbol = " ";

      time = {
        disabled = false;
        style = "bold italic";
        format = "[$time]($style)";
        time_format = "%a, %b %-d at %I:%M";
      };

      git_status = {
        format = "$staged$modified ";
        staged = " \${count} staged";
        modified = " \${count} modified";
      };

      git_branch.format = " $symbol$branch";

      cmd_duration.format = "took $duration";
    };
  };
}
