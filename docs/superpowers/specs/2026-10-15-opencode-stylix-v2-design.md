# OpenCode 2 Stylix theme migration

## Goal

Make the OpenCode 2.0.29 terminal client use the active Stylix palette through
`home/desktop/ai/opencode/default.nix`, including light appearance profiles.

## Design

Generate `$XDG_CONFIG_HOME/opencode/cli.json` with Home Manager's
`xdg.configFile` and the JSON format generator. Set the V2 CLI schema and
`theme.name = "stylix"`. Replace the existing `programs.opencode.tui` theme
selection, which writes the obsolete `tui.json`.

Replace the V1 theme object with a complete V2 theme document at
`opencode/themes/stylix.json`. Supply the semantic text, background, action,
form-field, feedback, border, scrollbar, diff, syntax, and Markdown tokens, plus
categorical hues and complete nine-step hue scales. Derive colors from
`config.lib.stylix.colors.withHashtag`.

Keep base00 as the background and base07 as the foreground for both appearance
profiles. Publish the active palette in both mode slots so terminal appearance
detection cannot invert the Stylix scheme. Preserve the current syntax and
Markdown color assignments where V2 has equivalent roles. Use contrasting
foregrounds for focused actions and selection backgrounds.

The local theme generator remains necessary because the pinned Stylix target and
Home Manager TUI option still target V1. Keep the Stylix OpenCode target
disabled. The existing OpenCode package override and server settings remain part
of the same module.

## Validation

- Format the edited Nix files with the repository's Nix formatter.
- Evaluate generated CLI and theme JSON for light and dark home profiles.
- Validate the complete theme against the pinned OpenCode V2 theme schema and
  reference resolver when the required runtime dependencies are available.
- Check the final diff for whitespace errors and unrelated changes.

Activation is a separate user action; these checks do not switch the active Home
Manager generation.
