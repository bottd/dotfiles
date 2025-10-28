{ nixpkgs-unstable, desktopEnvironment ? null, lib, pkgs, ... }: {
  home.packages = with nixpkgs-unstable; lib.optionals (desktopEnvironment != null && pkgs.stdenv.isLinux) [
    # inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
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
            "defaultModel": "claude-sonnet-4-20250514",
            "permissions": {
              "allow": [
                "mcp__context7__resolve-library-id",
                "mcp__context7__get-library-docs",
                "mcp__playwright__*",
                "mcp__sequential-thinking__*",
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
              "sequential-thinking": {
                "command": "npx",
                "args": [
                  "-y",
                  "@modelcontextprotocol/server-sequential-thinking"
                ]
              },
              "playwright": {
                "command": "npx",
                "args": [
                  "-y",
                  "@playwright/mcp@latest"
                ]
              },
              "context7": {
                "command": "npx",
                "args": [
                  "-y",
                  "@upstash/context7-mcp"
                ]
              },
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
