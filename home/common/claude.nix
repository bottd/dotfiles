{ pkgs, ... }: {
  home.packages = with pkgs; [
    claude-code
  ];

  home.file.".claude/settings.json" = {
    text =
      #json
      ''
                  {
          "permissions": {
            "allow": [],
            "deny": [
              "rm"
            ]
          }
        }
      '';
  };

}
