{ pkgs, neorgWorkspace, ... }: {
  home.packages = with pkgs; [
    neofetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=8"; # Gray ghost text color
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
