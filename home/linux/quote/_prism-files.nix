{ pkgs, appearance ? "dark" }:
let
  java = "${pkgs.temurin-bin-17}/bin/java";

  # Prism's registered application theme IDs are "system", "dark", "bright"
  # (no "light" — that was triggering ThemeWizardPage every launch because
  # isValidApplicationTheme rejected it, regenerating the welcome wizard).
  applicationTheme = if appearance == "light" then "bright" else "dark";
  iconTheme = if appearance == "light" then "pe_light" else "pe_dark";

  # Merges our keys into prismlauncher.cfg without clobbering Prism-owned
  # fields (accounts, last-used instance, window state, etc.). Idempotent.
  prism-apply-launcher-config = pkgs.writeShellApplication {
    name = "prism-apply-launcher-config";
    runtimeInputs = [ pkgs.crudini ];
    text = ''
      file="''${1:-}"
      [ -n "$file" ] || { echo "prism-apply-launcher-config: file path required" >&2; exit 1; }
      [ -f "$file" ] || printf '[General]\n' > "$file"
      set_kv() { crudini --ini-options=nospace --set "$file" General "$1" "$2"; }
      set_kv ApplicationTheme '${applicationTheme}'
      set_kv IconTheme '${iconTheme}'
      set_kv BackgroundCat kitteh
      set_kv JavaPath '${java}'
      set_kv AutomaticJavaSwitch false
      set_kv AutomaticJavaDownload false
    '';
  };

  # Merges our keys into an existing Prism instance.cfg without clobbering
  # Prism-owned fields (Name, InstanceType, iconKey, etc.). Idempotent.
  prism-apply-instance-config = pkgs.writeShellApplication {
    name = "prism-apply-instance-config";
    runtimeInputs = [ pkgs.crudini ];
    text = ''
      file="''${1:-}"
      [ -f "$file" ] || { echo "prism-apply-instance-config: file not found: $file" >&2; exit 1; }
      # Prism (QSettings) emits `key=value` with no spaces; nospace keeps us off
      # crudini's default `key = value` so the file stays byte-identical when no
      # value actually changes.
      set_kv() { crudini --ini-options=nospace --set "$file" General "$1" "$2"; }
      set_kv OverrideJavaLocation true
      set_kv JavaPath '${java}'
      set_kv OverrideMemory true
      set_kv MinMemAlloc 512
      set_kv MaxMemAlloc 4096
      set_kv OverrideJavaArgs true
      set_kv JvmArgs '-Ddirector.autoScreensaver=true'
    '';
  };
in
{
  inherit prism-apply-launcher-config prism-apply-instance-config;
}
