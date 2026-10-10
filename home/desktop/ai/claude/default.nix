{
  config,
  features,
  inputs,
  lib,
  nixpkgs-unstable,
  pkgs,
  system,
  ...
}:
{
  home = {
    packages = [
      nixpkgs-unstable.mcp-nixos
      inputs.claude-code.packages.${system}.default
    ];

    # Add native installer location to PATH on macOS
    sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
      "$HOME/.local/bin"
    ];

    file = {
      ".claude/settings.json".source =
        config.lib.meta.createSymlink "home/desktop/ai/claude/settings.json";
    };

    shellAliases = {
      claudepb = if pkgs.stdenv.isDarwin then ''claude "$(pbpaste)"'' else ''claude "$(wl-paste)"'';
    };
  };

  programs.git.ignores = [
    ".claude/settings.local.json"
    "CLAUDE.local.md"
    ".impeccable"
    "DESIGN.md"
  ];

  xdg.mimeApps = lib.mkIf (features.desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
