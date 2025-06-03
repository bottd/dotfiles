{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
    };
  };

  home.shellAliases = {
    zellij = ''zellij --theme "catppuccin-$([[ "$WINDOW_APPEARANCE" == "light" ]] && echo "latte" || echo "mocha")"'';
  };
}
