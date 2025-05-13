{inputs, ...}:
# Helper function to build standalone home-manager configurations
{
  hostName, # Host identifier from hosts.nix
  hostPath ? null, # Override path if default isn't used
  extraModules ? [], # Additional modules specific to this host
}: let
  hosts = import ../hosts.nix;
  host = hosts.hosts.${hostName};
  system = host.system;
  username = host.username;

  # Default path for host config, can be overridden
  path =
    if hostPath != null
    then hostPath
    else ../home/hosts/${hostName};
in
  inputs.home-manager.lib.homeManagerConfiguration {
    pkgs = import inputs.nixpkgs {
      inherit system;
      config.allowUnfree = true;
    };

    extraSpecialArgs = {
      inherit inputs host username system;
      inherit (inputs) nixpkgs;
    };

    modules =
      [
        # Import basic home-manager configuration
        ../home.nix

        # Host-specific configuration
        path

        # Extra modules
      ]
      ++ extraModules;
  }
