{
  config,
  lib,
  pkgs,
  inputs,
  system,
  ...
}:
let
  # upstream's source fileset drops ./script, which packages/cli's build imports
  opencode = inputs.opencode.packages.${system}.opencode.overrideAttrs (_: {
    src = inputs.opencode.outPath;
  });
  seo = pkgs.callPackage ../seo/package.nix { };
  colors = config.lib.stylix.colors.withHashtag;
in
{
  # The pinned Stylix target and Home Manager tui option still generate V1 config.
  stylix.targets.opencode.enable = false;

  xdg.configFile."opencode/cli.json".source = (pkgs.formats.json { }).generate "opencode-cli.json" {
    "$schema" = "https://opencode.ai/v2/cli.json";
    theme.name = "stylix";
  };

  programs.opencode = {
    enable = true;
    package = opencode;
    settings = {
      mcp.seo = {
        type = "local";
        command = [
          "${seo}/bin/seo"
          "mcp"
          "serve"
        ];
        enabled = true;
      };
      permission.external_directory = {
        "/nix/store/**" = "allow";
        "/tmp/**" = "allow";
        "~/dotfiles/**" = "allow";
        "~/workspace/**" = "allow";
        "~/loam/**" = "allow";
        "~/remote/**" = "allow";
        "~/.cargo/registry/**" = "allow";
        "~/.claude/**" = "allow";
        "~/.codex/**" = "allow";
        "~/.config/opencode/**" = "allow";
      };
    };

    themes.stylix = import ./theme.nix { inherit lib colors; };
  };
}
