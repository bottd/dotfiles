{ pkgs, ... }:
{
  programs.emacs = {
    enable = true;
    package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.emacs else pkgs.emacs-pgtk;
    extraPackages = epkgs: [
      epkgs.nix-mode
      epkgs.nixfmt

      epkgs.subed
      epkgs.vterm
    ];

    extraConfig = ''
      (with-eval-after-load 'subed
        (add-to-list 'auto-mode-alist '("\\.srt\\'" . subed-srt-mode)))
      (add-to-list 'auto-mode-alist '("\\.srt\\'" . subed-srt-mode))

      ;; subed bindings:
      ;;   M-n / M-p  next/previous subtitle      M-SPC    play/pause
      ;;   M-j        jump player to point        C-c C-l  loop current
      ;;   C-c ,      toggle player-follows-point
      ;;   C-c .      toggle point-follows-player
    '';
  };

  services.emacs.enable = true;
}
