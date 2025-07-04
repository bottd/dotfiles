{ pkgs
, inputs
, ...
}:
{
  imports = [
    inputs.nix-colors.homeManagerModules.default
  ];

  # Set Catppuccin color scheme from nix-colors
  colorScheme = inputs.nix-colors.colorSchemes.catppuccin-mocha;

  catppuccin = {
    flavor = "mocha";

    bat.enable = true;
    btop.enable = true;
    fish.enable = true;
    fzf.enable = true;
    starship.enable = true;
    zsh-syntax-highlighting.enable = true;

    delta.enable = true;
    lazygit.enable = true;

    micro.enable = true;
    yazi.enable = true;
    zellij.enable = true;

    cursors.enable = pkgs.stdenv.isLinux;
    cursors.flavor = "mocha";
    gtk.enable = true;
    hyprland.enable = false;

    thunderbird = {
      enable = true;
      profile = "drake";
    };
  };
}
