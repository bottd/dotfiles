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
    (paths.system + "/common/linux")
    (paths.system + "/users")
    (paths.home + "/common")
    (paths.home + "/linux")
  ];
}
