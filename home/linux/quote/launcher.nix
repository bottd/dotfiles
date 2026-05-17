{ config, pkgs, theme, ... }:
let
  prismDir = "${config.home.homeDirectory}/QuoteMC/prism";
  defaultPackRoot = "${config.home.homeDirectory}/workspace/3rd-brain";
  instanceId = "Quote-MC";
  prismFiles = import ./_prism-files.nix { inherit pkgs; inherit (theme) appearance; };

  # avoids buildEnv collision with the same name auto-built by home/common/scripts.nix
  inherit ((import ../../../scripts { inherit pkgs; })) quote-pack;

  # packwiz-installer materializes the local pack into a Prism instance's
  # .minecraft/, replacing the hand-rolled .pw.toml regex parser + downloader
  # that used to live in 3rd-brain/scripts/sync-mods.bb. We pin the bootstrap
  # AND the main installer jar so launches stay offline-deterministic — the
  # bootstrap's normal job is to self-update the installer from GitHub at run
  # time, which `--bootstrap-no-update --bootstrap-main-jar` short-circuits.
  packwizInstallerBootstrap = pkgs.fetchurl {
    url = "https://github.com/packwiz/packwiz-installer-bootstrap/releases/download/v0.0.3/packwiz-installer-bootstrap.jar";
    hash = "sha256-qPuyTcYEJ46X9GiOgtPZGjGLmO/AjV2/y8vKtkQ9EWw=";
  };
  packwizInstaller = pkgs.fetchurl {
    url = "https://github.com/packwiz/packwiz-installer/releases/download/v0.5.14/packwiz-installer.jar";
    hash = "sha256-yfZGkI00DYR3OUipp9mLwdriUNNeEBbcbiuEWXYLVZg=";
  };

  quote-mc-launch = pkgs.writeShellApplication {
    name = "quote-mc-launch";
    runtimeInputs = with pkgs; [
      prismlauncher
      temurin-bin-21
      git
      coreutils
      libnotify
      babashka
      packwiz
      quote-pack
      prismFiles.prism-apply-instance-config
      # MirrorCapture shells out to xdotool to resolve a window title to its
      # screen geometry; without it on PATH the lookup fails silently and
      # capture falls back to (0,0), grabbing whatever's at the screen origin.
      xdotool
      # Demo stage: Xephyr hosts a nested :2 X server whose framebuffer
      # MirrorCapture grabs into MC monitor blocks; firefox + ghostty are
      # the captured windows. MC stays on :0 fullscreen; :2 lives in a
      # background window so occlusion can't break the capture.
      xorg.xorgserver
      firefox
      ghostty
      # While attached, Xephyr's grab masks awesome's :0 Alt+F. xbindkeys runs
      # inside :2 and binds Alt+F to touch the detach-request flag rc.fnl polls.
      xbindkeys
    ];
    text = ''
      set -euo pipefail

      pack_root="''${QUOTE_PACK_ROOT:-${defaultPackRoot}}"
      export QUOTE_PACK_ROOT="$pack_root"
      # Consumed by 3rd-brain/scripts/sync-mods.bb (`bb sync` task).
      export PACKWIZ_INSTALLER_BOOTSTRAP_JAR='${packwizInstallerBootstrap}'
      export PACKWIZ_INSTALLER_JAR='${packwizInstaller}'
      instance_dir="${prismDir}/instances/${instanceId}"
      instance_cfg="$instance_dir/instance.cfg"
      instance_mods="$instance_dir/.minecraft/mods"

      if [ ! -d "$pack_root/modpack" ]; then
        echo "quote-mc-launch: $pack_root/modpack not found." >&2
        notify-send -u critical "quote-mc-launch" "pack missing at $pack_root" || true
        exit 1
      fi

      # first run: no .pw.toml means QoL mods aren't pinned yet
      if [ -z "$(find "$pack_root/modpack/mods" -maxdepth 1 -name '*.pw.toml' -print -quit 2>/dev/null || true)" ]; then
        quote-pack install-mods
      fi

      quote-pack pack

      if [ ! -d "$instance_dir" ]; then
        mrpack="$(find "$pack_root/modpack" -maxdepth 1 -name 'Quote-MC-*.mrpack' -print -quit || true)"
        if [ -z "$mrpack" ]; then
          echo "quote-mc-launch: no .mrpack found under $pack_root/modpack" >&2
          exit 1
        fi
        notify-send "Quote-MC" "First-time import: click OK in the dialog, then close Prism. Quote-MC will launch automatically." || true
        # No exec: we block on Prism, then continue once the user closes it.
        prismlauncher --dir "${prismDir}" --import "$mrpack" || true
        if [ ! -d "$instance_dir" ]; then
          notify-send -u critical "Quote-MC" "Import wasn't completed. Re-run quote-mc-launch when ready." || true
          exit 1
        fi
      fi

      # Idempotent: stamps our Java/memory/JvmArgs over Prism's import defaults.
      prism-apply-instance-config "$instance_cfg"

      quote-pack sync "$instance_mods"

      # Demo stage: ensure the nested :2 server and the captured windows are
      # up before MC launches. Each block is a no-op if the process already
      # exists, so re-running the launcher doesn't multiply.
      #
      # Capture geometry: the 3x2-block monitor wall captures 768x512 px
      # (DEFAULT_MIRROR_PIXELS_PER_BLOCK = 256). The :2 server is exactly that
      # size and firefox + ghostty are *stacked* — both sized to fill it, both
      # at (0,0). The capture rect is the whole screen; the lever just raises
      # whichever window it wants on top (MirrorCapture's resolveOffset raises
      # the title it is handed).
      cap_w=768
      cap_h=512

      # The demo stack (Xephyr :2 + its windows + xbindkeys) is reused across
      # launcher runs via the pgrep/search guards below. But a stack left over
      # from before a launcher change silently masks the new config — stale
      # Xephyr flags, stale window titles — because the guards see "already
      # running" and skip recreation. Stamp the stack; if a running one carries
      # a different stamp (or none), tear the whole thing down so it
      # regenerates clean. Bump demo_stamp whenever the demo spec below changes.
      director_dir="''${XDG_RUNTIME_DIR:-/tmp}/director"
      mkdir -p "$director_dir"
      demo_stamp_file="$director_dir/demo-stack.stamp"
      demo_stamp='v3-stacked'
      if pgrep -f 'Xephyr.*:2' >/dev/null \
         && [ "$(cat "$demo_stamp_file" 2>/dev/null || true)" != "$demo_stamp" ]; then
        pkill -f 'Xephyr.*:2' || true
        pkill -f 'xbindkeys.*xbindkeys-detach' || true
        rm -f "$demo_stamp_file"
        # firefox/ghostty on :2 exit on their own once the server is gone.
        sleep 1
      fi

      # -sw-cursor: render the pointer into Xephyr's framebuffer. The X cursor
      # is normally a separate sprite the server strips from XGetImage/x11grab
      # results, so MirrorCapture would mirror everything *except* the cursor.
      if ! pgrep -f 'Xephyr.*:2' >/dev/null; then
        Xephyr :2 -screen "$cap_w"x"$cap_h" -ac -sw-cursor >/dev/null 2>&1 &
        sleep 1
      fi
      if ! DISPLAY=:2 xdotool search --name firefox >/dev/null 2>&1; then
        # --no-remote + a dedicated profile: a plain `firefox` would hand the
        # URL to the existing :0 instance instead of opening a window on :2.
        # firefox errors ("profile cannot be loaded") if --profile points at a
        # path that doesn't exist — it won't create it, so mkdir first.
        mkdir -p "$HOME/.cache/quote-demo-ff"
        # Firefox seeds the new-tab top-sites grid with a sponsored tile
        # ("pinned from history" UI). A user.js in the profile disables it
        # before the window paints — rewritten each run since the prefs are
        # cheap and the profile may have been wiped.
        printf '%s\n' \
          'user_pref("browser.newtabpage.activity-stream.showSponsoredTopSites", false);' \
          'user_pref("browser.newtabpage.activity-stream.showSponsored", false);' \
          > "$HOME/.cache/quote-demo-ff/user.js"
        DISPLAY=:2 firefox --no-remote --profile "$HOME/.cache/quote-demo-ff" \
          'https://www.youtube.com/watch?v=QmCfdA4Nz0w' >/dev/null 2>&1 &
      fi
      if ! DISPLAY=:2 xdotool search --name ghostty >/dev/null 2>&1; then
        # Bare ghostty (no claude). --title pins the window title so the
        # shell inside can't rewrite it out from under MirrorCapture's
        # xdotool --name match.
        DISPLAY=:2 ghostty --title=ghostty >/dev/null 2>&1 &
      fi

      # :2 has no window manager, so windows spawn at their own default
      # geometry — size each to fill the :2 screen and stack both at (0,0).
      # They fully overlap; MirrorCapture raises whichever the lever selects.
      place_demo_window() {
        local name="$1" wid=""
        for _ in $(seq 1 50); do
          # `|| true` inside the subshell: xdotool exits 1 on no match, and
          # `set -o pipefail` would otherwise propagate that and trip `set -e`.
          wid="$(DISPLAY=:2 xdotool search --name "$name" 2>/dev/null | head -1 || true)"
          [ -n "$wid" ] && break
          sleep 0.2
        done
        if [ -n "$wid" ]; then
          DISPLAY=:2 xdotool windowsize "$wid" "$cap_w" "$cap_h" >/dev/null 2>&1 || true
          DISPLAY=:2 xdotool windowmove "$wid" 0 0 >/dev/null 2>&1 || true
        fi
      }
      place_demo_window firefox
      place_demo_window ghostty

      # xbindkeys on :2 binds Alt+F to `touch detach-request`; rc.fnl polls
      # that flag to detach (awesome's :0 Alt+F is masked by Xephyr's grab).
      xbindkeys_cfg="$director_dir/xbindkeys-detach.conf"
      printf '"touch %s/detach-request"\n  Alt + f\n' "$director_dir" > "$xbindkeys_cfg"
      if ! pgrep -f 'xbindkeys.*xbindkeys-detach' >/dev/null; then
        DISPLAY=:2 xbindkeys -n -f "$xbindkeys_cfg" >/dev/null 2>&1 &
      fi

      # Stack is fully up — record the stamp so the next launcher run reuses it
      # instead of tearing it down.
      printf '%s' "$demo_stamp" > "$demo_stamp_file"

      exec prismlauncher --dir "${prismDir}" --launch "${instanceId}"
    '';
  };
in
{
  home.packages = [ quote-mc-launch ];
}
