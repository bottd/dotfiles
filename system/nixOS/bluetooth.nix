{ features, ... }:
{
  hardware.bluetooth.enable = true;

  # Bluetooth tray applet + manager (KDE's Bluedevil is gone with Plasma).
  # GUI hosts only — headless hosts have no session to show the applet.
  services.blueman.enable = features.gui;
}
