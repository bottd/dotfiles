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
            "permissions": {
              "allow": [
                "mcp__svelte__*"
              ],
              "deny": [
                "rm"
              ]
            },
            "plugins": {
              "marketplaces": [
                {
                  "name": "superpowers-marketplace",
                  "url": "https://github.com/obra/superpowers-marketplace"
                }
              ],
              "installed": [
                {
                  "name": "superpowers",
                  "marketplace": "superpowers-marketplace"
                }
              ]
            },
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

      # superpowers plugin
      ".claude/plugins/superpowers" = {
        source = pkgs.fetchFromGitHub {
          owner = "obra";
          repo = "superpowers";
          rev = "main";
          sha256 = "sha256-hKzWAeD2zE+8vnnzluu5GB9BliqCCv+Jcwc5iOdXFD8=";
        };
        recursive = true;
      };
    };

  xdg.mimeApps = lib.mkIf (desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
