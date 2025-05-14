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

    (paths.systemModules + "/base")
    (paths.systemModules + "/common/darwin")
    (paths.systemModules + "/users")

    inputs.mac-app-util.darwinModules.default
    # {
    #   users.users.${username}.home = "/Users/${username}";
    # }
  ];
}
