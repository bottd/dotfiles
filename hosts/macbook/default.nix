{ username
, ...
}: {
  imports = [
    ./configuration.nix
    ../../system/users

    {
      users.users.${username}.home = "/Users/${username}";
    }
  ];
}
