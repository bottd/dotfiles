{ pkgs, ... }:

{
  # Install transmission with GTK interface
  environment.systemPackages = with pkgs; [
    transmission_4-gtk
  ];

  # Optional: Enable transmission daemon service
  # Uncomment below if you want to run transmission as a system service
  # services.transmission = {
  #   enable = true;
  #   settings = {
  #     download-dir = "/var/lib/transmission/Downloads";
  #     incomplete-dir = "/var/lib/transmission/.incomplete";
  #     rpc-whitelist = "127.0.0.1,192.168.*.*";
  #   };
  # };
}
