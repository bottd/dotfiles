{ pkgs, config, hostName, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#${config.lib.stylix.colors.base04}";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      export NIX_HOST="${hostName}"

      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then
        source "$HOME/.config/zsh/secrets.zsh"
      fi

      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };
}
