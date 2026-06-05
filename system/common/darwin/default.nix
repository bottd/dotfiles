{ inputs, lib, username, ... }:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    ./stylix.nix
  ];

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      mineffect = "scale";
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = true;
    };

    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
      "com.apple.sound.beep.feedback" = 0;
    };
  };

  # Home-manager copies Nix GUI apps as real bundles into ~/Applications/Home
  # Manager Apps, but they are unsigned and carry a com.apple.provenance xattr,
  # so Gatekeeper blocks them from launching. Strip provenance and ad-hoc
  # codesign them in place. (Newer mac-app-util no longer creates trampolines
  # when the source is a real copied directory, so we sign the copies directly.)
  system.activationScripts.postActivation.text = lib.mkAfter ''
    appsDir="/Users/${username}/Applications/Home Manager Apps"
    if [ -d "$appsDir" ]; then
      for app in "$appsDir"/*.app; do
        [ -d "$app" ] || continue
        /bin/chmod -R u+w "$app" 2>/dev/null || true
        /usr/bin/xattr -cr "$app" 2>/dev/null || true
        /usr/bin/codesign --force --deep --sign - "$app" 2>/dev/null || true
      done
    fi
  '';

  nixpkgs.hostPlatform = "aarch64-darwin";
}
