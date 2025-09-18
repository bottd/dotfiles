_:
{
  # Required for Android Terminal
  targets.genericLinux.enable = true;

  # Configure both bash and zsh with proper PATH handling
  programs.bash = {
    enable = true;
    bashrcExtra = ''
      # Force reload home-manager session vars
      if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
        unset __HM_SESS_VARS_SOURCED
        source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
      fi

      # Explicit PATH setup
      export PATH="$HOME/.nix-profile/bin:$PATH"
      export PATH="/nix/var/nix/profiles/default/bin:$PATH"
    '';
  };

  programs.zsh.initContent = ''
    # Force reload home-manager session vars for zsh
    if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      unset __HM_SESS_VARS_SOURCED
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi

    # Explicit PATH setup
    export PATH="$HOME/.nix-profile/bin:$PATH"
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
  '';
}
