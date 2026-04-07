{ config, username, inputs, host, lib, pkgs, ... }:
{
  users.users.${username} = lib.mkMerge [
    {
      description = "Drake Bott";
      packages = [ ];
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
      hashedPassword = "$6$RWnDqI6YSUzRNFcH$mYbS.1KQUPaNYRqK9C2So4oPy2hG7/sKCDDzDffv0jYkGk7g5O7uj8qWvMIRJi9kpmPOS5T3q49djmsYIhtyY.";
    })
    (lib.mkIf pkgs.stdenv.isDarwin { })
  ];

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      inherit (config._module.args) inputs host;
    };
  };
}
