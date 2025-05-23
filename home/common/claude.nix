{ nixpkgs-unstable, ... }: {
  home.packages = with nixpkgs-unstable; [
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
