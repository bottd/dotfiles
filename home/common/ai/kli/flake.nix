{
  description = "Drake's configured KLI image";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-unstable";
    kli = {
      url = "github:kleisli-io/kli";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    kli-kagi = {
      # Temporary local source while the extension is under development.
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
      homeDirectories = {
        x86_64-linux = "/home/drakeb";
        aarch64-linux = "/home/droid";
      };
      mkSandbox = home:
        let
          inHome = map (path: "${home}/${path}");
        in
        {
          writablePaths = inHome [
            ".cache/kli"
            ".config/kli"
            "chalet/_data/kli"
          ];
          denyRead = inHome [
            ".aws"
            ".claude"
            ".codex"
            ".config/Bitwarden"
            ".config/Bitwarden CLI"
            ".config/gh"
            ".config/opencode"
            ".config/rbw"
            ".docker"
            ".gnupg"
            ".kube"
            ".local/share"
            ".password-store"
            ".ssh"
          ];
        };
      mkConfiguredKli =
        system:
        let
          home = homeDirectories.${system} or null;
        in
        kli.lib.${system}.mkConfiguredKli {
          extensions = [ kli-kagi.packages.${system}.extension ];
          sandbox = if home == null then null else mkSandbox home;
        };
      mkKli =
        system:
        let
          pkgs = nixpkgs.legacyPackages.${system};
          configuredKli = mkConfiguredKli system;
          wrapper = pkgs.writers.writeBabashkaBin "kli" { } (
            builtins.replaceStrings
              [ "@rbw@" "@kli@" "@openssl-lib@" ]
              [ "${pkgs.rbw}/bin/rbw" "${configuredKli}/bin/kli" "${pkgs.openssl.out}/lib" ]
              (builtins.readFile ./wrapper.clj)
          );
        in
        pkgs.symlinkJoin {
          name = "kli";
          paths = [ configuredKli ];
          postBuild = ''
            rm "$out/bin/kli"
            ln -s ${wrapper}/bin/kli "$out/bin/kli"
          '';
        };
    in
    {
      packages = forEachSystem (
        system:
        let
          kli = mkKli system;
        in
        {
          default = kli;
          inherit kli;
        }
      );

      apps = forEachSystem (
        system:
        let
          kli = mkKli system;
        in
        {
          default = {
            type = "app";
            program = "${kli}/bin/kli";
            meta.description = "Run Drake's configured KLI image";
          };
        }
      );

      checks = forEachSystem (system: {
        manifest = (mkConfiguredKli system).manifestGate;
        kli-kagi-tests = kli-kagi.checks.${system}.tests;
        kli-kagi-source-load = kli-kagi.checks.${system}.source-load;
      });

      formatter = forEachSystem (system: nixpkgs.legacyPackages.${system}.nixfmt);
    };
}
