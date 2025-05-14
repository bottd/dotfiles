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
    (paths.systemModules + "/common/linux")
    (paths.systemModules + "/users")
  ];
}
