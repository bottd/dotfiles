{
  config,
  host,
  inputs,
  ...
}:
{
  # Workstations use the live checkout. Standalone profiles carry their config
  # in the generation so a server does not need a mutable ~/dotfiles checkout.
  lib.meta.createSymlink =
    path:
    if host.format == "home-manager" then
      "${inputs.self}/${path}"
    else
      config.lib.file.mkOutOfStoreSymlink "${config.home.homeDirectory}/dotfiles/${path}";

  imports = [
    ./cli.nix
    ./direnv.nix
    ./git.nix
    ./jujutsu.nix
    ./neovim
    ./starship
    ./stylix.nix
    ./zellij.nix
    ./zoxide.nix
    ./zsh.nix
  ];
}
