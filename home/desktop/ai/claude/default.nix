{
  config,
  features,
  inputs,
  lib,
  pkgs,
  system,
  ...
}:
let
  json = pkgs.formats.json { };
in
{
  options.claude.extraSettings = lib.mkOption {
    inherit (json) type;
    default = { };
    description = ''
      Settings merged over settings.json. Setting any replaces the live
      symlink with a generated file, so repo edits then need a rebuild.
    '';
  };

  config = {
    home = {
      packages = [
        inputs.claude-code.packages.${system}.default
      ];

      # Add native installer location to PATH on macOS
      sessionPath = lib.mkIf pkgs.stdenv.isDarwin [
        "$HOME/.local/bin"
      ];

      file = {
        ".claude/settings.json".source =
          if config.claude.extraSettings == { } then
            config.lib.meta.createSymlink "home/desktop/ai/claude/settings.json"
          else
            json.generate "claude-settings.json" (
              lib.recursiveUpdate (lib.importJSON ./settings.json) config.claude.extraSettings
            );
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
  };
}
