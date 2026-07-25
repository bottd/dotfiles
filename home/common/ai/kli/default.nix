{ config, inputs, lib, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
  stylixTheme = builtins.toJSON {
    name = "stylix";
    colors = import ../../../../lib/agentTheme.nix colors;
  };
  kli = inputs.kli-config.packages.${pkgs.stdenv.hostPlatform.system}.default;
in
{
  home = {
    # kli-kagi is a local Linux dev path and there's no darwin homeDirectory yet,
    # so kli only builds on Linux. ponytail: drop the guard once darwin is supported.
    packages = lib.mkIf pkgs.stdenv.isLinux [ kli ];

    activation.kliSandboxPaths = lib.mkIf pkgs.stdenv.isLinux (
      lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        $DRY_RUN_CMD mkdir -p \
          "${config.xdg.cacheHome}/kli" \
          "${config.xdg.configHome}/kli" \
          "${config.home.homeDirectory}/chalet/_data/kli"
      ''
    );

    file = {
      ".config/kli/settings.json".source =
        config.lib.meta.createSymlink "home/common/ai/kli/settings.json";
      ".config/kli/themes/stylix.json".text = stylixTheme;
      ".config/kli/extensions/stylix-theme.lisp".text = ''
        (defextension stylix-theme
          (:provides
           (theme stylix
             (kli/tui/style:load-theme
              #P"${config.home.homeDirectory}/.config/kli/themes/stylix.json"))
           (effect activate-stylix-theme
             (lambda (protocol contribution context)
               (declare (ignore contribution context))
               (prog1
                   (list (kli/tui/style:theme-name
                          (kli/tui/style:active-theme protocol))
                         (kli/ext:protocol-storage
                          protocol kli/tui/style:+theme-mode-key+))
                 (kli/tui/style:set-active-theme protocol "stylix")
                 (setf (kli/ext:protocol-storage
                        protocol kli/tui/style:+theme-mode-key+)
                       :explicit)))
             (lambda (protocol contribution context)
               (declare (ignore context))
               (destructuring-bind (previous-theme previous-mode)
                   (kli/ext:contribution-state contribution)
                 (when (kli/tui/style:find-theme protocol previous-theme)
                   (kli/tui/style:set-active-theme protocol previous-theme))
                 (setf (kli/ext:protocol-storage
                        protocol kli/tui/style:+theme-mode-key+)
                       previous-mode))))))
      '';
    };
  };
}
