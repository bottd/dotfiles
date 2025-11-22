{ pkgs
, ...
}: {
  programs.firefox = {
    enable = true;
    profiles.default = {
      settings = {
        "accessibility.force_disabled" = 1;
      };
    };
  };

  home.packages = with pkgs; [
    inkscape
  ];
}
