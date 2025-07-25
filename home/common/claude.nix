{ nixpkgs-unstable, config, ... }: {
  home.packages = with nixpkgs-unstable; [
    # temp: install globally with npm to get latest
    # nixpkgs unstable too slow for multiple updates/week
    # claude-code
  ];

  programs.git.ignores = [
    ".claude"
    "CLAUDE.md"
  ];

  home.file =
    let
      claudeConfig = #json
        ''
          {
              "permissions": {
                "allow": [
                  "mcp__context7__resolve-library-id",
                  "mcp__context7__get-library-docs",
                  "mcp__context7__search-libraries",
                  "mcp__context7__get-code-examples",
                  "mcp__context7__get-api-reference",
                  "mcp__filesystem__create_directory",
                  "mcp__filesystem__move_file",
                  "mcp__filesystem__copy_file",
                  "mcp__filesystem__list_directory",
                  "mcp__filesystem__get_file_info",
                  "mcp__filesystem__search_files",
                  "mcp__sequential-thinking__start_session",
                  "mcp__sequential-thinking__add_step",
                  "mcp__sequential-thinking__review_progress",
                  "mcp__playwright__navigate",
                  "mcp__playwright__screenshot",
                  "mcp__playwright__click",
                  "mcp__playwright__fill",
                  "mcp__playwright__select",
                  "mcp__playwright__hover",
                  "mcp__playwright__evaluate"
                ],
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
                "args": ["-y", "@modelcontextprotocol/server-filesystem", "${config.home.homeDirectory}"]
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
