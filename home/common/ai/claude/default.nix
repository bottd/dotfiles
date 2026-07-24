{ config, features, inputs, lib, pkgs, system, ... }:
{
  home = {
    packages = [ pkgs.mcp-nixos inputs.claude-code.packages.${system}.default ];

    # Add native installer location to PATH on macOS
    sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
      "$HOME/.local/bin"
    ];

    file = {
      # Live settings file in the dotfiles repo — mutable symlink so
      # `claude plugin install/uninstall` and other in-place edits land
      # back in this repo (git-tracked).
      ".claude/settings.json".source =
        config.lib.meta.createSymlink "home/common/ai/claude/settings.json";
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
    "CLAUDE.local.md"
  ];

  xdg.mimeApps = lib.mkIf (features.desktopEnvironment != null && pkgs.stdenv.isLinux) {
    associations.added = {
      "x-scheme-handler/claude" = "claude-desktop.desktop";
    };
  };
}
