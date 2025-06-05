{ username
, ...
}: {
  imports = [
    ./configuration.nix
    ../../system/base
    ../../system/users

    {
      users.users.${username}.home = "/Users/${username}";
    }
  ];
}
