{ config, username, ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";

    sddm = {
      enable = true;
      background = "${config.users.users.${username}.home}/.config/wallpapers/lighthouse.png";

      font = "MonoLisa Variable";
      fontSize = "11";

      # Login form position (if supported)
      # loginBackground = true; # Show background behind login form
    };
    grub.enable = false;
  };

  # Additional SDDM settings through NixOS options
  services.displayManager.sddm = {
    settings = {
      Theme = {
        # Show user avatar
        EnableAvatars = true;
        DisableAvatarsThreshold = 7;
      };

      General = {
        # Input behavior
        InputMethod = "";
        Numlock = "on";
      };
    };
  };
}
