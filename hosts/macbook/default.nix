{ username
, ...
}: {
  imports = [
    ./configuration.nix
    ../../system/base
    ../../system/common
    ../../system/users

    {
      users.users.${username}.home = "/Users/${username}";
    }
  ];
}
