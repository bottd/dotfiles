{ inputs
, username
, ...
}: {
  imports = [
    ./configuration.nix
    ../../system/base
    ../../system/users

    inputs.mac-app-util.darwinModules.default
    {
      users.users.${username}.home = "/Users/${username}";
    }
  ];
}
