# Darwin-specific common settings
{ ...
}: {
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

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # Set platform
  nixpkgs.hostPlatform = "aarch64-darwin";

  # Enable fonts
  fonts.fontDir.enable = true;
}
