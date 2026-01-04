{ config, desktopEnvironment ? null, lib, pkgs, inputs, ... }: {
  home =
    let
      helperPath = "${config.home.homeDirectory}/.local/bin/claude-api-key";
      claudeConfigCli =
        # json
        ''
          {
            "model": "opus",
            "env": {
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
      claudeConfigDesktop =
        # json
        ''
          {
            "model": "opus",
            "apiKeyHelper": "${helperPath}",
            "env": {
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
      packages = lib.optionals (desktopEnvironment != null && pkgs.stdenv.isLinux) [
        inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
      ];

      sessionVariables = {
        ANTHROPIC_BASE_URL = "https://api.z.ai/api/anthropic";
        API_TIMEOUT_MS = "3000000";
      };

      file = {
        # claude-code config
        ".claude/settings.json" = {
          text = claudeConfigCli;
        };

        # claude desktop config
        ".config/Claude/claude_desktop_config.json" = {
          text = claudeConfigDesktop;
        };

        ".local/bin/claude-api-key" = {
          text = ''
            #!/usr/bin/env bash
            set -euo pipefail

            if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then
              # shellcheck disable=SC1090
              source "$HOME/.config/zsh/secrets.zsh"
            fi

            token=${"$"}{ANTHROPIC_AUTH_TOKEN:-}
            if [ -z "$token" ]; then
              echo "ANTHROPIC_AUTH_TOKEN not set" >&2
              exit 1
            fi

            printf '%s' "$token"
          '';
          executable = true;
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
