{ pkgs, ... }:
let
  seo = pkgs.callPackage ./package.nix { };
in
{
  home = {
    packages = [ seo ];

    # Both Claude Code and OpenCode auto-load skills from ~/.claude/skills, so
    # the bundled skill is linked once from the pinned package. `seo skill
    # install` would copy it in instead and drift from whatever the flake ships.
    file.".claude/skills/seo".source = "${seo}/share/seo/skills/seo";
  };
}
