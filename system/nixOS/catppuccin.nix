{ ... }:
{
  catppuccin = {
    enable = true;
    flavor = "mocha";

    sddm = {
      enable = true;
      background = ../../../assets/wallpapers/lighthouse.png;
    };
    grub.enable = false;
  };
}
