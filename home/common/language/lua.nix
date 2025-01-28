{pkgs, ...}: {
  home.packages = with pkgs; [
    lua5_1
    luarocks

    lua-language-server
    stylua
  ];
}
