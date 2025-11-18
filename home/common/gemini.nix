_: {
  programs.git.ignores = [
    ".gemini/"
  ];

  home.file =
    let
      geminiConfig =
        # json
        ''
          {
            "previewFeatures": true
          }
        '';
    in
    {
      ".config/gemini/config.json" = {
        text = geminiConfig;
      };
    };
}
