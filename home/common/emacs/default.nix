{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt
    ];
  };

}
