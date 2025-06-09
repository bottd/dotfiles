{ config
, username
, inputs
, host
, lib
, pkgs
, ...
}: {
  users.users.${username} = lib.mkMerge [
    {
      description = "Drake Bott";
      packages = [ ];
    }
    (lib.mkIf pkgs.stdenv.isLinux {
      isNormalUser = true;
      extraGroups = [ "networkmanager" "wheel" ];
    })
    (lib.mkIf pkgs.stdenv.isDarwin { })
  ];

  # services.getty.autologinUser = username;

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      inherit (config._module.args) inputs host;
    };
  };
}
