{
  inputs,
  host,
  username,
  paths,
  ...
}: {
  imports = [
    # Local configuration using relative paths
    ./configuration.nix

    # Try using builtins.path for system modules
    (builtins.path {
      path = ../../modules;
      name = "system-modules";
    })

    # Home manager configuration
    {
      home-manager.users.${username} = {
        imports = [
          # Use builtins.path for home modules too
          (builtins.path {
            path = ../../../home.nix;
            name = "home-nix";
          })
          (builtins.path {
            path = ../../../home/linux;
            name = "home-linux";
          })
          (builtins.path {
            path = ../../../home/linux/hyprland/host/pocket.nix;
            name = "hyprland-pocket";
          })
          (builtins.path {
            path = ../../../home/common;
            name = "home-common";
          })
        ];
      };
    }
  ];
}
