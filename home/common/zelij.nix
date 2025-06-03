{ ... }:
{
  programs.zellij = {
    enable = true;
    settings = {
      theme = "catppuccin-mocha";
    };
  };

  # Since Zelij doesn't support automatic theme switching,
  # we use an alias that checks WINDOW_APPEARANCE env var
  home.shellAliases = {
    zellij = ''zellij --theme "catppuccin-$([[ "$WINDOW_APPEARANCE" == "light" ]] && echo "latte" || echo "mocha")"'';
  };
}
