{pkgs, ...}: {
  home.packages = with pkgs; [
    rustup
  ];
  # ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [ libiconv-darwin darwin.Security ]);
}
