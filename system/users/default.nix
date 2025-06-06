{ config
, username
, inputs
, host
, ...
}: {
  users.users.${username} = {
    description = "Drake Bott";
    packages = [ ];
  };

  home-manager = {
    useGlobalPkgs = true;
    useUserPackages = true;
    extraSpecialArgs = {
      inherit username;
      inherit (config._module.args) inputs host;
    };
  };
}
