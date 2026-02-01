{ desktopEnvironment ? null, lib, pkgs, ... }:
let
  claudeSettings = pkgs.writeText "claude-settings.json" (builtins.toJSON {
    permissions = {
      allow = [
        "mcp__svelte__*"
      ];
    };
    model = "opus";
    enabledPlugins = {
      "elements-of-style@superpowers-marketplace" = true;
      "superpowers-lab@superpowers-marketplace" = true;
    };
    preferNativeInstaller = false;
    plugins = { };
    mcpServers = {
      svelte = {
        command = "npx";
        args = [
          "-y"
          "@sveltejs/mcp"
        ];
      };
    };
  });
in
{
  # Add native installer location to PATH on macOS
  home.sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
    "$HOME/.local/bin"
  ];

  programs.git.ignores = [
    ".claude/settings.local.json"
  ];

  home.file = {
    # claude-code config
    ".claude/settings.json" = {
      source = claudeSettings;
    };

    # claude desktop config
    ".config/Claude/claude_desktop_config.json" = {
      source = claudeSettings;
    };
  };

  xdg.mimeApps = lib.mkIf (desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
