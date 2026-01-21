{ pkgs, config, ... }: {
  home.packages = with pkgs; [
    neofetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#${config.colorScheme.palette.base04}";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then
        source "$HOME/.config/zsh/secrets.zsh"
      fi

      export PATH="$HOME/.npm-packages/bin:$PATH"

      if [[ $- == *i* ]]; then
        neofetch
      fi
    '';
  };
}
