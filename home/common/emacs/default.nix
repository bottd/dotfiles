{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs else pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt

      epkgs.vterm
    ];
  };

  services.emacs.enable = true;
}
