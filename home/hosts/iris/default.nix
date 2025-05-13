{
  config,
  pkgs,
  username,
  ...
}: {
  imports = [
    ./configuration.nix
  ];

  home = {
    sessionVariables = {
      NEORG_WORKSPACE = "notes";
    };
  };
}
