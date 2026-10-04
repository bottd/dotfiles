{ lib }:
let
  load = import ../lib/inventory.nix { inherit lib; };
  definitions = import ../hosts;
  inventory = load definitions;
  accepts = hosts: (builtins.tryEval (builtins.deepSeq (load hosts) true)).success;
  desktopWith = change: { desktop = lib.recursiveUpdate definitions.desktop change; };
  expect = name: condition: lib.throwIfNot condition "Inventory test failed: ${name}" true;
in
builtins.all (result: result) [
  (expect "all current hosts are valid" (accepts definitions))
  (expect "unknown host field is rejected" (
    !accepts (desktopWith {
      usernmae = "typo";
    })
  ))
  (expect "unknown capability is rejected" (
    !accepts (desktopWith {
      features.gamming = true;
    })
  ))
  (expect "capabilities are typed" (
    !accepts (desktopWith {
      features.gaming = "true";
    })
  ))
  (expect "platform and format must agree" (
    !accepts (desktopWith {
      format = "darwin";
    })
  ))
  (expect "state versions match the format" (
    !accepts (desktopWith {
      stateVersion.system = 6;
    })
  ))
  (expect "state versions are required" (
    !accepts { desktop = builtins.removeAttrs definitions.desktop [ "stateVersion" ]; }
  ))
  (expect "headless hosts cannot enable desktop apps" (
    !accepts (desktopWith {
      features.desktopEnvironment = null;
      features.desktopApps = true;
    })
  ))
  (expect "default appearance is exported" (
    !accepts (desktopWith {
      appearances = [ "dark" ];
    })
  ))
  (expect "duplicate appearances are rejected" (
    !accepts (desktopWith {
      appearances = [
        "light"
        "light"
      ];
    })
  ))
  (expect "resource overrides are typed" (
    !accepts (desktopWith {
      nix.maxJobs = -1;
    })
  ))
  (expect "desktop resource defaults are retained" (
    inventory.desktop.nix.maxJobs == "auto"
    && inventory.desktop.nix.cores == 0
    && inventory.desktop.nix.keepOutputs
  ))
  (expect "Pocket has bounded parallelism" (
    inventory.pocket.nix.maxJobs == 2 && inventory.pocket.nix.cores == 2
  ))
  (expect "e-ink desktop and animation capabilities are separate" (
    inventory.eink.features.desktopEnvironment == "niri" && !inventory.eink.features.animations
  ))
]
