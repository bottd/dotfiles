_: {
  programs.git.ignores = [
    ".gemini/"
  ];

  home.file.".config/gemini/config.json".text =
    # json
    ''
      {
        "previewFeatures": true
      }
    '';
}
