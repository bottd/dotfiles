{
  description = "Drake's configured KLI image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kli = {
      url = "github:kleisli-io/kli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kli-kagi = {
      url = "path:/home/drakeb/workspace/kli-kagi";
      inputs.nixpkgs.follows = "nixpkgs";
      inputs.kli.follows = "kli";
    };
  };

  outputs =
    { nixpkgs
    , kli
    , kli-kagi
    , ...
    }:
    let
      systems = [
        "x86_64-linux"
        "aarch64-linux"
        "aarch64-darwin"
      ];
      forEachSystem = nixpkgs.lib.genAttrs systems;
      mkConfiguredKli =
        system:
        kli.lib.${system}.mkConfiguredKli {
          extensions = [ kli-kagi.packages.${system}.extension ];
        };
    in
    {
      packages = forEachSystem (
        system:
        let
          configuredKli = mkConfiguredKli system;
        in
        {
          default = configuredKli;
          kli = configuredKli;
        }
      );

      apps = forEachSystem (
        system:
        let
          configuredKli = mkConfiguredKli system;
        in
        {
          default = {
            type = "app";
            program = "${configuredKli}/bin/kli";
            meta.description = "Run Drake's configured KLI image";
          };
        }
      );

      checks = forEachSystem (system: {
        manifest = (mkConfiguredKli system).manifestGate;
        kli-kagi = kli-kagi.checks.${system}.integration;
      });

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
