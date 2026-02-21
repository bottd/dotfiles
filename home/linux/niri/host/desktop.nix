_: {
  programs.niri.settings = {
    outputs = {
      "DP-1" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 170.03;
        };
        position = {
          x = 0;
          y = 353;
        };
        layout = {
          preset-column-widths = [
            { proportion = 1.0 / 3.0; }
            { proportion = 1.0 / 2.0; }
            { proportion = 2.0 / 3.0; }
          ];
          default-column-width.proportion = 1.0 / 2.0;
        };
      };
      "DP-3" = {
        mode = {
          width = 2560;
          height = 1440;
          refresh = 59.91;
        };
        transform.rotation = 90;
        position = {
          x = 2560;
          y = 0;
        };
        layout = {
          preset-column-widths = [
            { proportion = 1.0 / 2.0; }
            { proportion = 1.0; }
          ];
          default-column-width.proportion = 1.0;
        };
      };
    };
  };
}
