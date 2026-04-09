{ theme, ... }:
let
  palette = if theme.appearance == "light" then "tokyonight_day" else "tokyonight_storm";
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".text = ''
    palette = "${palette}"
    format = """
    $time[ on ](text)$git_branch$git_state$jobs$shell$fill [$git_status](overlay0)
     $directory$character"""

    right_format = "$cmd_duration"

    [character]
    success_symbol = "[❯](bold lavender)"
    error_symbol = "[❯](bold red)"

    [directory]
    truncation_length = 4
    style = "bold lavender"

    [fill]
    symbol = " "

    [time]
    disabled = false
    style = "bold italic sky"
    format = "[$time]($style)"
    time_format = "%a, %b %e at %I:%M"

    [git_status]
    style = "overlay0"
    format = "[$staged]($style teal)[$modified]($style maroon) "
    staged = " ''${count} staged"
    modified = " ''${count} modified"

    [git_branch]
    style = "maroon"
    format = " [$symbol$branch]($style)"

    [cmd_duration]
    format = "[took $duration](yellow)"

    [palettes.tokyonight_storm]
    text = "#a9b1d6"
    lavender = "#bb9af7"
    maroon = "#f7768e"
    overlay0 = "#565f89"
    sky = "#7dcfff"
    teal = "#73daca"
    red = "#f7768e"
    yellow = "#e0af68"

    [palettes.tokyonight_day]
    text = "#3760bf"
    lavender = "#9854f1"
    maroon = "#f52a65"
    overlay0 = "#8990b3"
    sky = "#2e7de9"
    teal = "#387068"
    red = "#f52a65"
    yellow = "#8c6c3e"
  '';
}
