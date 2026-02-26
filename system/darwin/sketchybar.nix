_: {
  services.sketchybar = {
    enable = true;
    config = ''
      SKETCHYBAR_CONFIG="$HOME/.config/sketchybar"

      MAIN_DISPLAY=$(system_profiler SPDisplaysDataType | grep -B 3 'Main Display:' | awk '/Display Type/ {print $3}')

      if [[ $MAIN_DISPLAY = "Built-in" ]]; then
          source "$SKETCHYBAR_CONFIG/sketchybarrc-laptop"
      else
          source "$SKETCHYBAR_CONFIG/sketchybarrc-desktop"
      fi
    '';
  };
}
