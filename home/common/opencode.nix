{ pkgs, inputs, ... }: {
  home.packages = [
    inputs.opencode.packages.${pkgs.system}.default
  ];

  home.file =
    let
      opencodeConfig =
        # json
        ''
          {
            "$schema": "https://opencode.ai/config.json",
            "plugin": ["opencode-gemini-auth"],
            "theme": "catppuccin"
          }
        '';
    in
    {
      ".config/opencode/opencode.json" = {
        text = opencodeConfig;
      };
    };
}
