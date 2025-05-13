{
  config,
  pkgs,
  lib,
  username,
  paths,
  inputs,
  host,
  ...
}: {
  users.users.${username} = {
    isNormalUser = true;
    description = "Drake Bott";
    extraGroups = ["networkmanager" "wheel"];
    packages = [];
  };

  services.getty.autologinUser = username;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username paths;
      inherit (config._module.args) inputs host;
    };
  };
}
