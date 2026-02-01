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
  home = {
    # Add native installer location to PATH on macOS
    sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
      "$HOME/.local/bin"
    ];

    file = {
      # claude-code config
      ".claude/settings.json" = {
        source = claudeSettings;
      };

      # claude desktop config
      ".config/Claude/claude_desktop_config.json" = {
        source = claudeSettings;
      };
    };

    shellAliases = {
      claudepb =
        if pkgs.stdenv.isDarwin
        then ''claude "$(pbpaste)"''
        else ''claude "$(wl-paste)"'';
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
