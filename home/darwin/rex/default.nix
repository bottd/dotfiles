{
  config,
  lib,
  pkgs,
  ...
}:
let
  # The CLI ships inside the beta app bundle; there is no standalone install.
  rex = pkgs.writeShellScriptBin "rex" ''
    exec "/Applications/Rex Beta.app/Contents/Helpers/Rex Server.rex/Contents/MacOS/rex" "$@"
  '';

  # Stylix has no Rex target, so mirror its Ghostty one (and the Ghostty cursor
  # from home/common/ghostty.nix) as a Ghostty-format theme file.
  colors = config.lib.stylix.colors.withHashtag;
  palette = with colors; [
    base00
    base08
    base0B
    base0A
    base0D
    base0E
    base0C
    base05
    base03
    base08
    base0B
    base0A
    base0D
    base0E
    base0C
    base07
  ];
in
{
  home.packages = [ rex ];

  programs = {
    zsh.initContent = ''
      source <(${rex}/bin/rex completion zsh 2>/dev/null)
    '';

    # Read-only Rex community server (docs, changelog, Discord); OAuth via Discord.
    opencode.settings.mcp.superlogical = {
      type = "remote";
      url = "https://www.superlogical.com/rex/community-mcp";
      enabled = true;
    };
  };

  # Rex only reads Lua, so init.lua loads fennel and runs init.fnl at load time.
  # Rex does not watch these files; apply edits with `rex config reload`.
  xdg.configFile = {
    "rex/fennel.lua".source = "${pkgs.luajitPackages.fennel}/share/lua/5.1/fennel.lua";
    "rex/init.fnl".source = config.lib.meta.createSymlink "home/darwin/rex/init.fnl";
    "rex/init.lua".text = ''
      require("fennel").dofile("${config.xdg.configHome}/rex/init.fnl")
    '';

    # Rex can't pick a theme from init.lua. Import this once through the
    # palette's "Import Theme File"; Rex copies it, so re-import after a scheme change.
    "rex/themes/stylix".text = ''
      background = ${colors.base00}
      foreground = ${colors.base05}
      cursor-color = ${colors.base09}
      cursor-text = ${colors.base00}
      selection-background = ${colors.base02}
      selection-foreground = ${colors.base05}
      ${lib.concatImapStringsSep "\n" (i: c: "palette = ${toString (i - 1)}=${c}") palette}
    '';
  };

  # Same hook `rex skill setup` writes; the skill stub lives in ai/extensions.
  claude.extraSettings.hooks.SessionStart = [
    {
      hooks = [
        {
          type = "command";
          command = "/bin/sh -c 'rex __internal session-start --agent claude 2>/dev/null || true'";
          timeout = 5;
        }
      ];
    }
  ];
}
