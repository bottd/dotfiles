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
      "com.apple.swipescrolldirection" = false;
      "com.apple.sound.beep.feedback" = 0;
    };
  };

  nixpkgs.hostPlatform = "aarch64-darwin";
}
