{ pkgs, ... }:
let
  catppuccinStarship = pkgs.fetchFromGitHub {
    owner = "catppuccin";
    repo = "starship";
    rev = "main";
    sha256 = "sha256-FLHjbClpTqaK4n2qmepCPkb8rocaAo3qeV4Zp1hia0g=";
  };

  makeStarshipTheme = palette: {
    text = ''
      palette = "${if palette == "light" then "catppuccin_latte" else "catppuccin_mocha"}"
      format = """
      $time[ on ](text)$git_branch$git_state $cmd_duration$jobs$shell$fill [$git_status](overlay0)
       $directory$character"""

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
      format = "[$staged]($style teal)[$modified]($style maroon)"
      staged = " ''${count} staged"
      modified = " ''${count} modified"

      [git_branch]
      style = "maroon"
      format = " [$symbol$branch]($style)"

      ${builtins.readFile "${catppuccinStarship}/themes/latte.toml"}
      ${builtins.readFile "${catppuccinStarship}/themes/mocha.toml"}
    '';
  };
in
{
  programs.starship = {
    enable = true;
    enableBashIntegration = true;
    enableZshIntegration = true;
  };

  xdg.configFile = {
    "starship.toml" = makeStarshipTheme "dark";
    "starship/light.toml" = makeStarshipTheme "light";
    "starship/dark.toml" = makeStarshipTheme "dark";
  };
}
