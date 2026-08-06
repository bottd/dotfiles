{ config, lib, pkgs, ... }:
let
  scripts = import ../../scripts { inherit pkgs; };
in
{
  # Home-manager copies Nix GUI apps as real bundles into ~/Applications/Home
  # Manager Apps, but they are unsigned and carry a com.apple.provenance xattr,
  # so Gatekeeper blocks them from launching. Strip provenance and ad-hoc
  # codesign them in place. (Newer mac-app-util no longer creates trampolines
  # when the source is a real copied directory, so we sign the copies directly.)
  #
  # `trampolineApps` is mac-app-util's own activation entry — the copies do not
  # exist until it has run.
  home.activation.signHomeManagerApps = lib.hm.dag.entryAfter [ "trampolineApps" ] ''
    run ${lib.getExe scripts.darwin-sign-apps} \
      ${lib.escapeShellArg "${config.home.homeDirectory}/Applications/Home Manager Apps"}
  '';
}
