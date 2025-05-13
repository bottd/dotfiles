{
  inputs,
  host,
  username,
  paths,
  ...
}: {
  imports = [
    ./configuration.nix
    paths.systemModules
    inputs.mac-app-util.darwinModules.default
    {
      users.users.${username}.home = "/Users/${username}";
      home-manager.users.${username} = {
        imports = [
          inputs.mac-app-util.homeManagerModules.default
          (paths.root + "/home.nix")
          (paths.homeDarwin)
          (paths.homeCommon)
        ];
      };
    }
  ];
}
