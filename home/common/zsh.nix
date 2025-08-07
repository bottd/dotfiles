{ pkgs, neorgWorkspace, ... }: {
  home.packages = with pkgs; [
    neofetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    syntaxHighlighting.enable = true;
    initContent = ''
      export NEORG_WORKSPACE=${neorgWorkspace}
      export NEORG_WORKSPACE_PATH=~/${neorgWorkspace}
      
      if [[ $- == *i* ]]; then
        neofetch
      fi
    '';
  };
}
