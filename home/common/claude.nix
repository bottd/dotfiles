{ desktopEnvironment ? null, lib, pkgs, inputs, ... }: {
  home.packages = lib.optionals (desktopEnvironment != null && pkgs.stdenv.isLinux) [
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
  ];

  programs.git.ignores = [
    ".claude/settings.local.json"
  ];

  home.file =
    let
      claudeConfig =
        # json
        ''
          {
            "model": "opus",
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

  xdg.mimeApps = lib.mkIf (desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
