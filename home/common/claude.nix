{ config, features, inputs, lib, pkgs, system, ... }:
let
  # Live settings file in the dotfiles repo.
  # Symlinked into place via mkOutOfStoreSymlink so `claude plugin install/uninstall`
  # and other in-place edits land back in this repo (git-tracked).
  claudeSettingsPath = "${config.home.homeDirectory}/dotfiles/home/common/claude-settings.json";
in
{
  home = {
    packages = [ inputs.claude-code.packages.${system}.default ];

    # Add native installer location to PATH on macOS
    sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
      "$HOME/.local/bin"
    ];

    file = {
      # claude-code config — mutable symlink to the file in dotfiles.
      ".claude/settings.json".source =
        config.lib.file.mkOutOfStoreSymlink claudeSettingsPath;
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
