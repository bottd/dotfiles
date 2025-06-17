{ pkgs, ... }:
let
  # Fetch catppuccin starship themes from GitHub
  catppuccinStarship = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "starship";
    rev = "main";
    sha256 = "sha256-1w0TJdQP5lb9jCrCmhPlSexf0PkAlcz8GBDEsRjPRns=";
  };

  makeStarshipTheme = palette: ''
    palette = "${if palette == "light" then "catppuccin_latte" else "catppuccin_mocha"}"
    format = """
    [┌$fill](bold blue)
    [│](bold blue) $time
    [│](bold blue) $all
    [└───> ](bold blue)"""

    [character]
    disabled = true

    [directory]
    truncation_length = 4
    style = "bold lavender"

    [fill]
    symbol = "─"
    style = "bold lavender"

    [git_branch]
    style = "bold maroon"

    [line_break]
    disabled = true

    [time]
    disabled = false
    style = "italic sky"
    format = "[$time]($style)"
    time_format = "%A, %B %e at %I:%M%P"

    ${builtins.readFile "${catppuccinStarship}/themes/latte.toml"}
    ${builtins.readFile "${catppuccinStarship}/themes/mocha.toml"}
  '';
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile = {
    "starship/starship.dark.toml".text = makeStarshipTheme "dark";
    "starship/starship.light.toml".text = makeStarshipTheme "light";
  };
}
