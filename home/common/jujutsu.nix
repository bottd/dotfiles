{ pkgs, ... }: {
  programs.jujutsu = {
    enable = true;
    settings = {
      git = {
        auto-local-bookmark = true;
      };
    };
  };

  home.packages = with pkgs; [
    lazyjj
  ];
}