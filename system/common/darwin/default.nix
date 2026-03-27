{ inputs, lib, username, ... }:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    ../../darwin/sketchybar.nix
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

  # mac-app-util trampolines inherit com.apple.provenance from the Nix store
  system.activationScripts.postActivation.text = lib.mkAfter ''
    /usr/bin/xattr -d com.apple.quarantine /Users/${username}/Applications/"Home Manager Trampolines"/*.app 2>/dev/null
    /usr/bin/xattr -d com.apple.provenance /Users/${username}/Applications/"Home Manager Trampolines"/*.app 2>/dev/null
  '';

  nixpkgs.hostPlatform = "aarch64-darwin";
}
