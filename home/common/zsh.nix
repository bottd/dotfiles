{ pkgs, hostName, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion.enable = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export NIX_HOST="${hostName}"

      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then
        source "$HOME/.config/zsh/secrets.zsh"
      fi

      export PATH="$HOME/.npm-packages/bin:$PATH"

      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };
}
