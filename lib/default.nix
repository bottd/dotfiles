{inputs}: let
  # Import hosts registry
  hosts = import ../hosts.nix;

  # System builder function
  mkSystem = {
    hostName,
    extraModules ? [],
    ...
  }: let
    host = hosts.hosts.${hostName};
    system = host.system;
    username = host.username;

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
          # Add home-manager as a module
          (
            if host.format == "nixos"
            then inputs.home-manager.nixosModules.home-manager
            else inputs.home-manager.darwinModules.home-manager
          )

          # Home manager settings
          {
            home-manager = {
              useGlobalPkgs = true;
              useUserPackages = true;
              extraSpecialArgs = {
                inherit inputs host username system;
                inherit (inputs) nixpkgs;
              };
            };
          }

          # Extra modules
        ]
        ++ extraModules;
    };

  # Home manager standalone builder
  mkHome = {
    hostName,
    extraModules ? [],
    ...
  }: let
    host = hosts.hosts.${hostName};
    system = host.system;
    username = host.username;
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

      modules = extraModules;
    };
in {
  inherit hosts mkSystem mkHome;
}
