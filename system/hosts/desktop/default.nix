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

    # Try using inputs.self directly
    (inputs.self + "/system/modules")

    # Home manager configuration
    {
      home-manager.users.${username} = {
        imports = [
          # Use inputs.self directly for home modules
          (inputs.self + "/home.nix")
          (inputs.self + "/home/linux")
          (inputs.self + "/home/linux/hyprland/host/desktop.nix")
          (inputs.self + "/home/common")
        ];
      };
    }
  ];
}
