{ pkgs, neorgWorkspace, config, ... }: {
  home.packages = with pkgs; [
    neofetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#${config.colorScheme.palette.overlay0}";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      export PATH="$HOME/.npm-packages/bin:$PATH"
      export NEORG_WORKSPACE=${neorgWorkspace}
      export NEORG_WORKSPACE_PATH=~/${neorgWorkspace}

      if [[ $- == *i* ]]; then
        neofetch
      fi
    '';
  };
}
