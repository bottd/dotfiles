{ config, lib, pkgs, theme, ... }:
let
  prismDir = "${config.home.homeDirectory}/QuoteMC/prism";
  instanceCfg = "${prismDir}/instances/Quote-MC/instance.cfg";
  prismFiles = import ./_prism-files.nix { inherit pkgs; inherit (theme) appearance; };
in
{
  home.packages = [
    prismFiles.prism-apply-launcher-config
    prismFiles.prism-apply-instance-config
  ];

  home.activation.prismConfig =
    lib.hm.dag.entryAfter [ "writeBoundary" "quoteSandbox" ] ''
      run ${prismFiles.prism-apply-launcher-config}/bin/prism-apply-launcher-config '${prismDir}/prismlauncher.cfg'
      if [ -f '${instanceCfg}' ]; then
        run ${prismFiles.prism-apply-instance-config}/bin/prism-apply-instance-config '${instanceCfg}'
      fi
    '';
}
