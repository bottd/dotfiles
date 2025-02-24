{pkgs, ...}: {
  nixpkgs.config.allowUnfreePredicate = pkg:
    builtins.elem (lib.getName pkg) [
      "steam"
    ];

  home.packages = with pkgs; [
    steam
  ];
}
