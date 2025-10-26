{ pkgs, ... }:
let
  # Helper to create a Babashka script from a .clj file
  mkBabashkaScript = name: path: pkgs.writeScriptBin name ''
    #!${pkgs.babashka}/bin/bb
    ${builtins.readFile path}
  '';

  # Get all .clj files in this directory
  scriptFiles = builtins.readDir ./.;

  # Filter to only .clj files and create script bins
  scripts = builtins.listToAttrs (
    builtins.map
      (name:
        let
          # Remove .clj extension for the command name
          scriptName = builtins.replaceStrings [ ".clj" ] [ "" ] name;
        in
        {
          name = scriptName;
          value = mkBabashkaScript scriptName (./. + "/${name}");
        }
      )
      (builtins.filter
        (name:
          builtins.match ".*\\.clj" name != null
        )
        (builtins.attrNames scriptFiles))
  );
in
scripts
