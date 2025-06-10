{ nixpkgs-unstable, inputs, ... }: {
  home.packages = with nixpkgs-unstable; [
    claude-code
    inputs.claude-desktop.packages.${pkgs.system}.claude-desktop-with-fhs
  ];

  home.file =
    let
      claudeConfig = #json
        ''
          {
              "permissions": {
                "allow": [],
                "deny": [
                  "rm"
                ]
              },
            "mcpServers": {
              "Context7": {
                "command": "npx",
                "args": ["-y", "@upstash/context7-mcp"]
              },
              "filesystem": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-filesystem", "/home/drakeb"]
              },
              "sequential-thinking": {
                "command": "npx",
                "args": ["-y", "@modelcontextprotocol/server-sequential-thinking"]
              },
              "playwright": {
                "command": "npx",
                "args": ["@playwright/mcp@latest"]
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

}
