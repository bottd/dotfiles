{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory systems;
  runners = {
    x86_64-linux = "ubuntu-24.04";
    aarch64-linux = "ubuntu-24.04-arm";
    aarch64-darwin = "macos-15";
  };
in
{
  flake.ci = {
    hosts.include = lib.mapAttrsToList (name: host: {
      inherit name;
      inherit (host) system;
      runner = runners.${host.system};
      targets = map (
        variant:
        if host.format == "nixos" then
          "nixosConfigurations.${variant}.config.system.build.toplevel"
        else
          "darwinConfigurations.${variant}.system"
      ) ([ name ] ++ map (appearance: "${name}-${appearance}") host.appearances);
    }) inventory;
    platforms.include = map (system: {
      inherit system;
      runner = runners.${system};
    }) systems;
  };
}
