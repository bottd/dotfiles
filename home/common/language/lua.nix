{pkgs, ...}: {
  home.packages = with pkgs; [
    # Needed for building rocks
    lua5_1

    lua-language-server
    stylua
  ];
}
