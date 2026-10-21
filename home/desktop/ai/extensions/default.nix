{
  lib,
  pkgs,
  inputs,
  ...
}:
{
  # Claude Code gets impeccable through its plugin marketplace, so only OpenCode
  # needs it from the flake. Upstream ships an OpenCode-specific build.
  programs.opencode.settings.skills.paths = [ "${inputs.impeccable}/.opencode/skills" ];
  xdg.configFile."opencode/commands/impeccable.md".source =
    "${inputs.impeccable}/.opencode/commands/impeccable.md";

  # The stub `rex skill setup` writes; the guide itself comes from the CLI.
  # OpenCode also loads skills from ~/.claude/skills. Rex only ships for macOS.
  home.file.".claude/skills/rex/SKILL.md" = lib.mkIf pkgs.stdenv.isDarwin {
    source = ./rex/SKILL.md;
  };
}
