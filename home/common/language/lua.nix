{pkgs, ...}: {
  home.packages = with pkgs; [
    # Needed for building rocks
    lua5_1
    luarocks
    lua-language-server
    stylua
  ];
}
