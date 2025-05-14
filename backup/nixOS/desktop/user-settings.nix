# User management wrapper module - mirroring system/modules/users
# This approach duplicates content from new structure to avoid path issues
{
  config,
  pkgs,
  lib,
  ...
}: let
  # Hard-coded username - will be replaced with a parameter in the future
  username = "drakeb";
in {
  # Define user accounts
  users.users.${username} = {
    isNormalUser = true;
    description = "Drake Bott";
    extraGroups = ["networkmanager" "wheel"];
    packages = [];
  };

  # Enable automatic login for the user
  services.getty.autologinUser = username;

  # Configure home-manager for the user
  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
  };
}
