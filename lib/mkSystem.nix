{inputs, ...}:
# Helper function to build system configurations (NixOS or Darwin)
{
  hostName, # Host identifier from hosts.nix
  hostPath ? null, # Override path if default isn't used
  extraModules ? [], # Additional modules specific to this system
}: let
  hosts = import ../hosts.nix;
  host = hosts.hosts.${hostName};
  system = host.system;
  username = host.username;

  # Default path for host config, can be overridden
  path =
    if hostPath != null
    then hostPath
    else ../system/hosts/${hostName};

  # Select the appropriate system builder based on format
  systemBuilder =
    if host.format == "nixos"
    then inputs.nixpkgs.lib.nixosSystem
    else if host.format == "darwin"
    then inputs.nix-darwin.lib.darwinSystem
    else throw "Unsupported system format: ${host.format}";
in
  systemBuilder {
    inherit system;
    specialArgs = {
      inherit inputs host username system;
      inherit (inputs) nixpkgs;
    };
    modules =
      [
        # Base configuration from path
        path

        # Add home-manager as a module
        (
          if host.format == "nixos"
          then inputs.home-manager.nixosModules.home-manager
          else inputs.home-manager.darwinModules.home-manager
        )

        # Extra modules
      ]
      ++ extraModules;
  }
