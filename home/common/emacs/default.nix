{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    defaultEditor = false;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt
    ];
  };

}
