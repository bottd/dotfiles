{ inputs, ... }:
let
  inherit (inputs.nixpkgs) lib;
  inherit (import ../lib { inherit inputs; }) inventory mkHomeModules mkSpecialArgs;
  homes = lib.filterAttrs (
    _: host: host.format == "home-manager" && lib.hasSuffix "-linux" host.system
  ) inventory;
in
{
  # The standalone activation and NixOS integration share exactly the same modules.
  flake.nixosModules = lib.mapAttrs (_: host: { pkgs, ... }: {
    imports = [ inputs.home-manager.nixosModules.home-manager ];
    assertions = [
      {
        assertion = pkgs.stdenv.hostPlatform.system == host.system;
        message = "The dotfiles ${host.hostName} home profile requires ${host.system}.";
      }
    ];
    home-manager = {
      useGlobalPkgs = true;
      useUserPackages = true;
      extraSpecialArgs = mkSpecialArgs host;
      users.${host.username}.imports = mkHomeModules host;
    };
    programs.zsh.enable = true;
    users.users.${host.username}.shell = pkgs.zsh;
  }) homes;
}
