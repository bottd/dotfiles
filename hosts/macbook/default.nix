{
  inputs,
  host,
  username,
  lib,
  config,
  ...
}: {
  imports = [
    ./configuration.nix
    ../../system/base
    ../../common/darwin
    ../../users

    inputs.mac-app-util.darwinModules.default
    # {
    #   users.users.${username}.home = "/Users/${username}";
    # }
  ];
}
