{
  inputs,
  host,
  username,
  paths,
  lib,
  config,
  ...
}: {
  imports = [
    ./configuration.nix

    (paths.system + "/base")
    (paths.system + "/common/darwin")
    (paths.system + "/users")

    inputs.mac-app-util.darwinModules.default
    # {
    #   users.users.${username}.home = "/Users/${username}";
    # }
  ];
}
