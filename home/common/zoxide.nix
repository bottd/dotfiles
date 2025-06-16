{
  programs.zoxide = {
    enable = true;
    enableNushellIntegration = true;
    enableZshIntegration = true;
    options = [ "--cmd cd" ];
  };
}
