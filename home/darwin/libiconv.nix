{pkgs, ...}: {
  home.packages = with pkgs; [
    libiconv
  ];

  home.sessionVariables = {
    LIBRARY_PATH = "${pkgs.libiconv}/lib";
    CPATH = "${pkgs.libiconv}/include";
  };
}
