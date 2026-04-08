{ inputs, lib, username, ... }:
{
  imports = [
    inputs.mac-app-util.darwinModules.default
    ./stylix.nix
    ../../darwin/sketchybar.nix
  ];

  system.defaults = {
    dock = {
      autohide = true;
      orientation = "bottom";
      showhidden = true;
      mineffect = "scale";
      mru-spaces = false;
    };

    finder = {
      AppleShowAllExtensions = true;
      FXEnableExtensionChangeWarning = false;
      CreateDesktop = true;
    };

    NSGlobalDomain = {
      "com.apple.swipescrolldirection" = false;
      "com.apple.sound.beep.feedback" = 0;
    };
  };

  # Trampoline apps open the real .app in /nix/store via AppleScript, but Gatekeeper
  # blocks unsigned Nix store apps. Copy them to a writable location, strip provenance,
  # and codesign so macOS will allow them to launch.
  system.activationScripts.postActivation.text = lib.mkAfter ''
    nixAppsDir="/Users/${username}/Applications/Nix Apps"
    trampolinesDir="/Users/${username}/Applications/Home Manager Trampolines"
    /bin/mkdir -p "$nixAppsDir"

    # Prevent Spotlight from indexing trampolines (avoids duplicate entries)
    [ -f "$trampolinesDir/.metadata_never_index" ] || /usr/bin/touch "$trampolinesDir/.metadata_never_index"

    for trampoline in "$trampolinesDir"/*.app; do
      [ -d "$trampoline" ] || continue
      name=$(/usr/bin/basename "$trampoline")

      # .scpt is compiled AppleScript; strings extracts the open target
      scpt="$trampoline/Contents/Resources/Scripts/main.scpt"
      [ -f "$scpt" ] || continue
      storePath=$(/usr/bin/strings "$scpt" | /usr/bin/grep -o "/nix/store/[^'\"]*\.app" | head -1 || true)
      [ -n "$storePath" ] && [ -d "$storePath" ] || continue

      # Skip if already copied from this exact store path
      dest="$nixAppsDir/$name"
      stamp="$dest/.nix-store-path"
      if [ -f "$stamp" ] && [ "$(/bin/cat "$stamp")" = "$storePath" ]; then
        continue
      fi

      /bin/rm -rf "$dest"
      /bin/cp -RL "$storePath" "$dest"
      /bin/chmod -R u+w "$dest"
      /usr/bin/xattr -cr "$dest" 2>/dev/null
      /usr/bin/codesign --force --deep --sign - "$dest" 2>/dev/null
      echo "$storePath" > "$stamp"
    done
  '';

  nixpkgs.hostPlatform = "aarch64-darwin";
}
