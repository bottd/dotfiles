{ inputs, ... }:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    ../nix.nix
    ../stylix.nix
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
      _HIHideMenuBar = false;
      "com.apple.swipescrolldirection" = false;
      "com.apple.sound.beep.feedback" = 0;
    };

    # Siri off: assistant, menu bar icon, "Hey Siri", audio sharing.
    CustomUserPreferences = {
      "com.apple.assistant.support"."Assistant Enabled" = false;
      "com.apple.Siri" = {
        StatusMenuVisible = false;
        VoiceTriggerUserEnabled = false;
        "Siri Data Sharing Opt-In Status" = 2;
      };
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
