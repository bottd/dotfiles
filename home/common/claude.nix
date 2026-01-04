{ desktopEnvironment ? null, lib, pkgs, inputs, ... }: {
  home = {
    packages = lib.optionals (desktopEnvironment != null && pkgs.stdenv.isLinux) [
      inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
    ];

    sessionVariables = {
      ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
      API_TIMEOUT_MS = "3000000";
    };

    file =
      let
        claudeConfig =
          # json
          ''
            {
              "model": "opus",
              "env": {
                "ANTHROPIC_AUTH_TOKEN": "$ANTHROPIC_AUTH_TOKEN",
                "ANTHROPIC_BASE_URL": "https://api.z.ai/api/anthropic",
                "API_TIMEOUT_MS": "3000000"
              },
              "permissions": {
                "allow": [
                  "mcp__svelte__*"
                ]
              },
              "plugins": {},
              "mcpServers": {
                "svelte": {
                  "command": "npx",
                  "args": [
                    "-y",
                    "@sveltejs/mcp"
                  ]
                }
              }
            }
          '';
      in
      {
        # claude-code config
        ".claude/settings.json" = {
          text = claudeConfig;
        };

        # claude desktop config
        ".config/Claude/claude_desktop_config.json" = {
          text = claudeConfig;
        };
      };
  };

  programs.git.ignores = [
    ".claude/settings.local.json"
  ];

  xdg.mimeApps = lib.mkIf (desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
