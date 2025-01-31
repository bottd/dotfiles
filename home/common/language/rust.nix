{pkgs, ...}: {
  home.packages = with pkgs; [
    rustup
    rlwrap
    sqlite
    nil
  ] ++ (pkgs.lib.optionals pkgs.stdenv.isDarwin [ libiconv-darwin darwin.Security ]);
}
