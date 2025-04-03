{pkgs, ...}: {
  home.packages = with pkgs; [
    jdt-language-server
    vscode-extensions.vscjava.vscode-java-test
    vscode-extensions.vscjava.vscode-java-debug
    vscode-extensions.vscjava.vscode-gradle
  ];
}
