{ pkgs, config, hostName, ... }:
{
  home.packages = with pkgs; [
    fastfetch
  ];

  programs.zsh = {
    enable = true;
    enableCompletion = true;
    autosuggestion = {
      enable = true;
      highlight = "fg=#${config.lib.stylix.colors.base04}";
    };
    syntaxHighlighting.enable = true;
    initContent = ''
      export NIX_HOST="${hostName}"

      nix_appearance_file="''${XDG_STATE_HOME:-$HOME/.local/state}/dotfiles/rebuild-appearance"
      if [ -f "$nix_appearance_file" ]; then
        case "$(< "$nix_appearance_file")" in
          light|dark) export NIX_APPEARANCE="$(< "$nix_appearance_file")" ;;
        esac
      fi
      unset nix_appearance_file

      if [ -f "$HOME/.config/zsh/secrets.zsh" ]; then
        source "$HOME/.config/zsh/secrets.zsh"
      fi

      if [[ $- == *i* ]]; then
        fastfetch
      fi
    '';
  };
}
