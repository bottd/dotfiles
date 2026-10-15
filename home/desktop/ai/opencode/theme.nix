{ lib, colors }:
let
  inherit (colors)
    base00
    base01
    base02
    base03
    base04
    base05
    base06
    base07
    base08
    base09
    base0A
    base0B
    base0C
    base0D
    base0E
    ;

  # Blend toward the scheme's foreground/background, so light schemes keep
  # their contrast direction without assuming black or white endpoints.
  mix =
    from: to: percent:
    "#"
    +
      lib.concatMapStrings
        (
          offset:
          let
            channel = color: lib.fromHexString (builtins.substring offset 2 color);
            value = builtins.div (channel from * (100 - percent) + channel to * percent) 100;
          in
          lib.toLower (lib.fixedWidthString 2 "0" (lib.toHexString value))
        )
        [
          1
          3
          5
        ];
  scale = color: {
    "100" = mix color base07 35;
    "200" = color;
    "300" = mix color base00 15;
    "400" = mix color base00 30;
    "500" = mix color base00 45;
    "600" = mix color base00 60;
    "700" = mix color base00 75;
    "800" = mix color base00 85;
    "900" = mix color base00 95;
  };
  hue = {
    gray = {
      "100" = base07;
      "200" = base06;
      "300" = base05;
      "400" = base04;
      "500" = base03;
      "600" = base02;
      "700" = base01;
      "800" = base00;
      "900" = base00;
    };
    red = scale base08;
    orange = scale base09;
    yellow = scale base0A;
    green = scale base0B;
    cyan = scale base0C;
    blue = scale base0D;
    purple = scale base0E;
    accent = "$hue.cyan";
    interactive = "$hue.blue";
    neutral = "$hue.gray";
  };
  feedback = {
    error = base08;
    warning = base0A;
    success = base0B;
    info = base0D;
  };
in
{
  # Both slots intentionally use the active Stylix scheme: terminal mode
  # detection must not invert a light palette's foreground and background.
  light = { inherit hue; };
  dark = { inherit hue; };
  base = {
    categorical = [
      "purple"
      "cyan"
      "green"
      "yellow"
      "blue"
      "red"
      "orange"
    ];
    text = {
      base = base07;
      muted = base04;
      action = {
        primary = {
          base = base07;
          "$hovered" = base0D;
          "$focused" = base00;
          "$selected" = base00;
          "$disabled" = base04;
        };
        secondary = {
          base = base04;
          "$hovered" = base07;
        };
        destructive = {
          base = base00;
          "$disabled" = base04;
        };
      };
      formfield = {
        base = base07;
        "$disabled" = base04;
      };
      feedback = lib.mapAttrs (_: color: { base = color; }) feedback;
    };
    background = {
      base = base00;
      raised = {
        base = base01;
        high = base02;
        max = base03;
      };
      action = {
        primary = {
          base = "transparent";
          "$hovered" = base01;
          "$focused" = base0D;
          "$selected" = base0D;
        };
        secondary = {
          base = "transparent";
          "$hovered" = base01;
        };
        destructive = {
          base = base08;
          "$disabled" = base02;
        };
      };
      formfield.base = "$background.base";
      feedback = lib.mapAttrs (_: _: { base = "$background.base"; }) feedback;
    };
    border.base = base03;
    scrollbar.base = base0D;
    diff = {
      text = {
        added = base0B;
        removed = base08;
        context = base04;
        hunkHeader = base0D;
      };
      background = {
        added = mix base0B base00 90;
        removed = mix base08 base00 90;
        context = base00;
      };
      highlight = {
        added = mix base0B base00 75;
        removed = mix base08 base00 75;
      };
      lineNumber = {
        text = base04;
        background = {
          added = mix base0B base00 90;
          removed = mix base08 base00 90;
        };
      };
    };
    syntax = {
      comment = base04;
      keyword = base0E;
      function = base0D;
      variable = base08;
      string = base0B;
      number = base09;
      type = base0A;
      operator = base0C;
      punctuation = base05;
    };
    markdown = {
      text = base07;
      heading = base0E;
      link = base0D;
      linkText = base0C;
      code = base0B;
      blockQuote = base05;
      emphasis = base0A;
      strong = base07;
      horizontalRule = base03;
      listItem = base0C;
      listEnumeration = base09;
      image = base0D;
      imageText = base0C;
      codeBlock = base07;
    };
    "@dialog".background = {
      base = "$background.raised.base";
      action.primary."$hovered" = "$background.raised.high";
    };
  };
}
