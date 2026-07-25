_: {
  programs.jujutsu = {
    enable = true;
    settings = {
      git = {
        auto-local-bookmark = true;
      };
    };
  };
}
