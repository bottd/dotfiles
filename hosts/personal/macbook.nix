# 2023 MacBook Pro M2 Max 14"
{root, home, ...}: {
  imports = [
    (root + /packages/darwin/default.nix)
    (root + /packages/common/default.nix)
  ];
  home.username = "drakebott";
  programs.zsh.initExtra = ''
    export NEORG_WORKSPACE=chalet
    export NEORG_WORKSPACE_PATH=~/chalet
  '';
  #environment.pathsToLink = [ "/share/zsh" ];
  #home.file.".config/zsh/.zshrc-personal-laptop".source = ../dotfiles/zsh/personal-laptop.zsh;
}
