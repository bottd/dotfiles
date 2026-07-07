{ username, ... }: {
  imports = [
    ./configuration.nix
  ];

  users.users.${username}.home = "/Users/${username}";
}
