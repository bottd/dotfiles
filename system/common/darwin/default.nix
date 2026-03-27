# Darwin-specific common settings
{ inputs, pkgs, ... }:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    ../../darwin/sketchybar.nix
  ];

  # Darwin-specific settings
  system.defaults = {
    # Dock settings
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      mineffect = "scale";
      mru-spaces = false;
    };

    # Finder settings
    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = true;
    };

    # Global settings
    NSGlobalDomain = {
      AppleShowAllExtensions = true;
      "com.apple.swipescrolldirection" = false;
      "com.apple.sound.beep.feedback" = 0;
    };
  };

  system.activationScripts.postActivation.text = ''
    ${pkgs.findutils}/bin/find ~/Applications/"Home Manager Trampolines" -maxdepth 1 -name '*.app' -exec /usr/bin/xattr -cr {} + 2>/dev/null || true
  '';

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set platform
  nixpkgs.hostPlatform = "aarch64-darwin";
}
