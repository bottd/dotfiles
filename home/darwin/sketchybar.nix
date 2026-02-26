_: {
  home.file = {
    ".config/sketchybar/sketchybarrc-main" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        FONT_FACE="MonoLisa Nerd Font"
        ICON_FONT="MonoLisa Nerd Font"
        RIFT_CLI="/opt/homebrew/bin/rift-cli"
        PLUGIN_DIR="$HOME/.config/sketchybar/plugins"

        SPOTIFY_EVENT="com.spotify.client.PlaybackStateChanged"

        sketchybar --bar \
            height=32 \
            color=0x00000000 \
            margin=16 \
            sticky=on \
            padding_left=16 \
            padding_right=16 \
            notch_width=188 \
            display=main \
            y_offset=8

        sketchybar --default \
            background.color=0x66494d64 \
            background.corner_radius=5 \
            background.padding_right=5 \
            background.height=26 \
            icon.font="$ICON_FONT:Medium:18.0" \
            icon.padding_left=5 \
            icon.padding_right=5 \
            label.font="$FONT_FACE:Medium:14.0" \
            label.color=0xffcad3f5 \
            label.y_offset=0 \
            label.padding_left=0 \
            label.padding_right=5

        # Rift workspace changed event
        sketchybar --add event rift_workspace_changed

        # Workspace indicators
        for i in 1 2 3 4 5; do
            sketchybar --add item workspace_$i left \
                --set workspace_$i \
                background.color=0x00000000 \
                background.corner_radius=5 \
                background.padding_left=0 \
                background.padding_right=0 \
                icon=$i \
                icon.font="$FONT_FACE:Bold:14.0" \
                icon.color=0xffcad3f5 \
                icon.padding_left=10 \
                icon.padding_right=10 \
                label.drawing=off \
                click_script="/opt/homebrew/bin/rift-cli execute workspace switch $((i - 1))" \
                script="$PLUGIN_DIR/workspace.sh" \
                --subscribe workspace_$i rift_workspace_changed
        done

        sketchybar --add item front_app left \
            --set front_app \
            background.color=0xffa6da95 \
            background.padding_left=0 \
            background.padding_right=0 \
            icon.y_offset=1 \
            icon.color=0xff24273a \
            label.drawing=no \
            script="$PLUGIN_DIR/front_app.sh" \
            --add item front_app.separator left \
            --set front_app.separator \
            background.color=0x00000000 \
            background.padding_left=-3 \
            icon= \
            icon.color=0xffa6da95 \
            icon.font="$ICON_FONT:Bold:22.0" \
            icon.padding_left=0 \
            icon.padding_right=0 \
            icon.y_offset=1 \
            label.drawing=no \
            --add item front_app.name left \
            --set front_app.name \
            background.color=0x00000000 \
            background.padding_right=0 \
            icon.drawing=off \
            label.font="$FONT_FACE:Bold:14.0" \
            label.drawing=yes

        sketchybar --add bracket front_app_bracket \
            front_app \
            front_app.separator \
            front_app.name \
            --subscribe front_app front_app_switched

        sketchybar --add item weather.moon right \
            --set weather.moon \
            background.color=0x667dc4e4 \
            background.padding_right=-1 \
            icon.color=0xff181926 \
            icon.font="$ICON_FONT:Bold:26.0" \
            icon.padding_left=4 \
            icon.padding_right=3 \
            label.drawing=off \
            --subscribe weather.moon mouse.clicked

        sketchybar --add item weather right \
            --set weather \
            icon= \
            icon.color=0xfff5bde6 \
            icon.font="$ICON_FONT:Bold:18.0" \
            update_freq=1800 \
            script="$PLUGIN_DIR/weather.sh" \
            --subscribe weather system_woke

        sketchybar --add item clock right \
            --set clock \
            icon=󰃰 \
            icon.color=0xffed8796 \
            update_freq=10 \
            script="$PLUGIN_DIR/clock.sh"

        sketchybar --add item battery right \
            --set battery \
            update_freq=20 \
            script="$PLUGIN_DIR/battery.sh"

        sketchybar --add item volume right \
            --set volume \
            icon.color=0xff8aadf4 \
            label.drawing=true \
            script="$PLUGIN_DIR/volume.sh" \
            --subscribe volume volume_change

        sketchybar --add event spotify_change $SPOTIFY_EVENT \
            --add item spotify right \
            --set spotify \
            icon= \
            icon.y_offset=1 \
            label.drawing=off \
            label.padding_left=3 \
            script="$PLUGIN_DIR/spotify.sh" \
            --subscribe spotify spotify_change mouse.clicked

        ##### Finalizing Setup #####
        sketchybar --update
        sketchybar --trigger rift_workspace_changed

        # Subscribe to rift workspace events via mach IPC
        ($RIFT_CLI subscribe mach workspace_changed | while read -r line; do
            /run/current-system/sw/bin/sketchybar --trigger rift_workspace_changed
        done) &
      '';
    };

    # Plugins
    ".config/sketchybar/plugins/workspace.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        RIFT_CLI="/opt/homebrew/bin/rift-cli"

        # Extract workspace index from item name (workspace_1 -> 0, workspace_2 -> 1, etc.)
        WORKSPACE_NUM=''${NAME##workspace_}
        WORKSPACE_INDEX=$((WORKSPACE_NUM - 1))

        WORKSPACES_JSON=$($RIFT_CLI query workspaces 2>/dev/null)

        if [[ -z "$WORKSPACES_JSON" ]]; then
            return
        fi

        ACTIVE_INDEX=$(echo "$WORKSPACES_JSON" | jq -r '.[] | select(.is_active) | .index')
        WINDOW_COUNT=$(echo "$WORKSPACES_JSON" | jq -r ".[] | select(.index == $WORKSPACE_INDEX) | .window_count")

        if [[ "$WORKSPACE_INDEX" -eq "$ACTIVE_INDEX" ]]; then
            sketchybar --set $NAME \
                background.color=0xfff5a97f \
                icon.color=0xff24273a
        elif [[ "$WINDOW_COUNT" -gt 0 ]]; then
            sketchybar --set $NAME \
                background.color=0x66494d64 \
                icon.color=0xffcad3f5
        else
            sketchybar --set $NAME \
                background.color=0x00000000 \
                icon.color=0xff6e738d
        fi
      '';
    };

    ".config/sketchybar/plugins/clock.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh
        sketchybar --set $NAME label="$(date '+%a %b %-d %-H:%M')"
      '';
    };

    ".config/sketchybar/plugins/front_app.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        ICON_PADDING_RIGHT=5

        case $INFO in
        "Arc")
            ICON_PADDING_RIGHT=5
            ICON=󰞍
            ;;
        "Code")
            ICON_PADDING_RIGHT=4
            ICON=󰨞
            ;;
        "Calendar")
            ICON_PADDING_RIGHT=3
            ICON=
            ;;
        "Discord")
            ICON=
            ;;
        "FaceTime")
            ICON_PADDING_RIGHT=5
            ICON=
            ;;
        "Finder")
            ICON=󰀶
            ;;
        "Ghostty")
            ICON=󰆍
            ;;
        "Google Chrome")
            ICON_PADDING_RIGHT=7
            ICON=
            ;;
        "IINA")
            ICON_PADDING_RIGHT=4
            ICON=󰕼
            ;;
        "kitty")
            ICON=󰄛
            ;;
        "Messages")
            ICON=
            ;;
        "Notion")
            ICON_PADDING_RIGHT=6
            ICON=󰎚
            ;;
        "Preview")
            ICON_PADDING_RIGHT=3
            ICON=
            ;;
        "Spotify")
            ICON_PADDING_RIGHT=2
            ICON=
            ;;
        "TextEdit")
            ICON_PADDING_RIGHT=4
            ICON=
            ;;
        "Zen")
            ICON=󰖟
            ;;
        *)
            ICON_PADDING_RIGHT=2
            ICON=
            ;;
        esac

        sketchybar --set $NAME icon=$ICON icon.padding_right=$ICON_PADDING_RIGHT
        sketchybar --set $NAME.name label="$INFO"
      '';
    };

    ".config/sketchybar/plugins/volume.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        case ''${INFO} in
        0)
            ICON=""
            ICON_PADDING_RIGHT=21
            ;;
        [0-9])
            ICON=""
            ICON_PADDING_RIGHT=12
            ;;
        *)
            ICON=""
            ICON_PADDING_RIGHT=6
            ;;
        esac

        sketchybar --set $NAME icon=$ICON icon.padding_right=$ICON_PADDING_RIGHT label="$INFO%"
      '';
    };

    ".config/sketchybar/plugins/weather.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        LOCATION="Chicago"
        WEATHER_JSON=$(curl -s "https://wttr.in/Chicago?format=j1")

        if [ -z $WEATHER_JSON ]; then
            sketchybar --set $NAME label=$LOCATION
            sketchybar --set $NAME.moon icon=
            return
        fi

        TEMPERATURE=$(echo $WEATHER_JSON | jq '.current_condition[0].temp_C' | tr -d '"')
        WEATHER_DESCRIPTION=$(echo $WEATHER_JSON | jq '.current_condition[0].weatherDesc[0].value' | tr -d '"' | sed 's/\(.\{25\}\).*/\1.../')
        MOON_PHASE=$(echo $WEATHER_JSON | jq '.weather[0].astronomy[0].moon_phase' | tr -d '"')

        case ''${MOON_PHASE} in
        "New Moon")
            ICON=
            ;;
        "Waxing Crescent")
            ICON=
            ;;
        "First Quarter")
            ICON=
            ;;
        "Waxing Gibbous")
            ICON=
            ;;
        "Full Moon")
            ICON=
            ;;
        "Waning Gibbous")
            ICON=
            ;;
        "Last Quarter")
            ICON=
            ;;
        "Waning Crescent")
            ICON=
            ;;
        esac

        sketchybar --set $NAME label="$LOCATION  $TEMPERATURE℃ $WEATHER_DESCRIPTION"
        sketchybar --set $NAME.moon icon=$ICON
      '';
    };

    ".config/sketchybar/plugins/battery.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env sh

        PERCENTAGE=$(pmset -g batt | grep -Eo "\d+%" | cut -d% -f1)
        CHARGING=$(pmset -g batt | grep 'AC Power')

        if [ $PERCENTAGE = "" ]; then
            exit 0
        fi

        case ''${PERCENTAGE} in
        [8-9][0-9] | 100)
            ICON=""
            ICON_COLOR=0xffa6da95
            ;;
        7[0-9])
            ICON=""
            ICON_COLOR=0xffeed49f
            ;;
        [4-6][0-9])
            ICON=""
            ICON_COLOR=0xfff5a97f
            ;;
        [1-3][0-9])
            ICON=""
            ICON_COLOR=0xffee99a0
            ;;
        [0-9])
            ICON=""
            ICON_COLOR=0xffed8796
            ;;
        esac

        if [[ $CHARGING != "" ]]; then
            ICON=""
            ICON_COLOR=0xffeed49f
        fi

        sketchybar --set $NAME \
            icon=$ICON \
            label="''${PERCENTAGE}%" \
            icon.color=''${ICON_COLOR}
      '';
    };

    ".config/sketchybar/plugins/spotify.sh" = {
      executable = true;
      text = ''
        #!/usr/bin/env zsh

        MAX_LENGTH=35
        HALF_LENGTH=$(((MAX_LENGTH + 1) / 2))

        SPOTIFY_JSON="$INFO"

        update_track() {
            if [[ -z $SPOTIFY_JSON ]]; then
                sketchybar --set $NAME icon.color=0xffeed49f label.drawing=no
                return
            fi

            PLAYER_STATE=$(echo "$SPOTIFY_JSON" | jq -r '.["Player State"]')

            if [ $PLAYER_STATE = "Playing" ]; then
                TRACK="$(echo "$SPOTIFY_JSON" | jq -r .Name)"
                ARTIST="$(echo "$SPOTIFY_JSON" | jq -r .Artist)"

                TRACK_LENGTH=''${#TRACK}
                ARTIST_LENGTH=''${#ARTIST}

                if [ $((TRACK_LENGTH + ARTIST_LENGTH)) -gt $MAX_LENGTH ]; then
                    if [ $TRACK_LENGTH -gt $HALF_LENGTH ] && [ $ARTIST_LENGTH -gt $HALF_LENGTH ]; then
                        TRACK="''${TRACK:0:$((MAX_LENGTH % 2 == 0 ? HALF_LENGTH - 2 : HALF_LENGTH - 1))}…"
                        ARTIST="''${ARTIST:0:$((HALF_LENGTH - 2))}…"
                    elif [ $TRACK_LENGTH -gt $HALF_LENGTH ]; then
                        TRACK="''${TRACK:0:$((MAX_LENGTH - ARTIST_LENGTH - 1))}…"
                    elif [ $ARTIST_LENGTH -gt $HALF_LENGTH ]; then
                        ARTIST="''${ARTIST:0:$((MAX_LENGTH - TRACK_LENGTH - 1))}…"
                    fi
                fi
                sketchybar --set $NAME label="''${TRACK}  ''${ARTIST}" label.drawing=yes icon.color=0xffa6da95

            elif [ $PLAYER_STATE = "Paused" ]; then
                sketchybar --set $NAME icon.color=0xffeed49f
            elif [ $PLAYER_STATE = "Stopped" ]; then
                sketchybar --set $NAME icon.color=0xffeed49f label.drawing=no
            else
                sketchybar --set $NAME icon.color=0xffeed49f
            fi
        }

        case "$SENDER" in
        "mouse.clicked")
            osascript -e 'tell application "Spotify" to playpause'
            ;;
        *)
            update_track
            ;;
        esac
      '';
    };
  };
}
