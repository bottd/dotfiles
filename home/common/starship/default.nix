{ config, ... }:
let
  palette = config.lib.stylix.colors;
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile."starship.toml".text = ''
    palette = "stylix"
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

    [palettes.stylix]
    text = "#${palette.base05}"
    lavender = "#${palette.base0E}"
    maroon = "#${palette.base08}"
    overlay0 = "#${palette.base04}"
    sky = "#${palette.base0D}"
    teal = "#${palette.base0C}"
    red = "#${palette.base08}"
    yellow = "#${palette.base0A}"
  '';
}
