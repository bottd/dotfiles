{ config, inputs, pkgs, ... }:
let
  colors = config.lib.stylix.colors;
  hex = color: "#${color}";
  stylixTheme = builtins.toJSON {
    name = "stylix";
    colors = {
      accent = hex colors.base0D;
      border = hex colors.base03;
      borderAccent = hex colors.base0D;
      borderMuted = hex colors.base02;
      success = hex colors.base0B;
      error = hex colors.base08;
      warning = hex colors.base0A;
      muted = hex colors.base04;
      dim = hex colors.base03;
      text = hex colors.base07;
      thinkingText = hex colors.base05;
      selectedBg = hex colors.base02;
      userMessageBg = hex colors.base01;
      userMessageText = hex colors.base07;
      customMessageBg = hex colors.base01;
      customMessageText = hex colors.base07;
      customMessageLabel = hex colors.base0E;
      toolPendingBg = hex colors.base01;
      toolSuccessBg = hex colors.base01;
      toolErrorBg = hex colors.base01;
      toolTitle = hex colors.base0D;
      toolOutput = hex colors.base06;
      mdHeading = hex colors.base0E;
      mdLink = hex colors.base0D;
      mdLinkUrl = hex colors.base0C;
      mdCode = hex colors.base0B;
      mdCodeBlock = hex colors.base06;
      mdCodeBlockBorder = hex colors.base03;
      mdQuote = hex colors.base05;
      mdQuoteBorder = hex colors.base03;
      mdHr = hex colors.base03;
      mdListBullet = hex colors.base0C;
      toolDiffAdded = hex colors.base0B;
      toolDiffRemoved = hex colors.base08;
      toolDiffContext = hex colors.base04;
      syntaxComment = hex colors.base04;
      syntaxKeyword = hex colors.base0E;
      syntaxFunction = hex colors.base0D;
      syntaxVariable = hex colors.base08;
      syntaxString = hex colors.base0B;
      syntaxNumber = hex colors.base09;
      syntaxType = hex colors.base0A;
      syntaxOperator = hex colors.base0C;
      syntaxPunctuation = hex colors.base05;
      thinkingOff = hex colors.base04;
      thinkingMinimal = hex colors.base0D;
      thinkingLow = hex colors.base0C;
      thinkingMedium = hex colors.base0B;
      thinkingHigh = hex colors.base0A;
      thinkingXhigh = hex colors.base09;
      bashMode = hex colors.base09;
    };
  };
  configuredKli = inputs.kli.lib.${pkgs.stdenv.hostPlatform.system}.mkConfiguredKli {
    inherit (config.programs.kli) extensions settings registries blessedNativeLibs dataDir sandbox;
  };
in
{
  imports = [ inputs.kli.homeManagerModules.default ];

  programs.kli = {
    enable = true;
    # buildLisp's runtime wrapper only sets LD_LIBRARY_PATH; macOS needs DYLD_LIBRARY_PATH.
    package = pkgs.symlinkJoin {
      name = "kli";
      paths = [ configuredKli ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm "$out/bin/kli"
        makeWrapper ${configuredKli}/bin/kli "$out/bin/kli" \
          --prefix DYLD_LIBRARY_PATH : "${pkgs.openssl.out}/lib"
      '';
    };
  };

  home.file = {
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
}
