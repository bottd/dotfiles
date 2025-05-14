{pkgs, ...}: {
  home.packages = with pkgs; [
    lua5_1
    lua51Packages.luarocks

    lua-language-server
    lux-cli
    stylua
  ];
}
