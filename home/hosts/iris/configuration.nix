{
  programs.zsh = {
    enable = true;
    initExtra = ''
      # Source Nix environment if it exists
      if [ -e '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh' ]; then
        . '/nix/var/nix/profiles/default/etc/profile.d/nix-daemon.sh'
      fi
    '';
  };
}
