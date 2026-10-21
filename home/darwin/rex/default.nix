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
in
{
  home.packages = [ rex ];

  programs = {
    # Rex replaces zellij here.
    zellij.enable = lib.mkForce false;

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
