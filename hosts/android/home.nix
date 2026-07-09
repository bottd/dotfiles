let
  # Force reload home-manager session vars and put nix profiles on PATH.
  pathFix = ''
    if [ -f "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh" ]; then
      unset __HM_SESS_VARS_SOURCED
      source "$HOME/.nix-profile/etc/profile.d/hm-session-vars.sh"
    fi

    export PATH="$HOME/.nix-profile/bin:$PATH"
    export PATH="/nix/var/nix/profiles/default/bin:$PATH"
  '';
in
_:
{
  # Required for Android Terminal
  targets.genericLinux.enable = true;

  # Disable GPU driver integration since Android doesn't need desktop GPU drivers
  # and the Intel/AMD GPU packages are x86-only
  targets.genericLinux.gpu.enable = false;

  programs.bash = {
    enable = true;
    bashrcExtra = pathFix;
  };

  programs.zsh.initContent = pathFix;
}
