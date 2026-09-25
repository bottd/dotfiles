{ config
, pkgs
, inputs
, system
, ...
}:
let
  tresorit-fhs = inputs.nix-tresorit.packages.${system}.default;
  tresorit-launcher = pkgs.writeShellScriptBin "tresorit-fhs-launch" ''
    if [ ! -x "$HOME/.local/share/tresorit/tresorit" ]; then
      printf '%s\n' "Tresorit is not installed. Run 'nix run ~/dotfiles#tresorit-install' first." >&2
      exit 1
    fi

    export QT_QPA_PLATFORM=xcb
    export QT_STYLE_OVERRIDE=
    exec ${tresorit-fhs}/bin/tresorit-fhs -c "$HOME/.local/share/tresorit/tresorit --hidden" \
      >> "$HOME/.local/share/tresorit/fhs.log" 2>&1
  '';
  tresorit-desktop-entry = pkgs.writeText "tresorit-fhs.desktop" ''
    [Desktop Entry]
    Type=Application
    Name=Tresorit
    GenericName=Secure file synchronisation
    Exec=${tresorit-launcher}/bin/tresorit-fhs-launch
    TryExec=${tresorit-launcher}/bin/tresorit-fhs-launch
    Icon=${config.home.homeDirectory}/.local/share/tresorit/tresorit.png
    MimeType=x-scheme-handler/tresorit;
    Categories=Network;FileTransfer;
    StartupNotify=true
  '';
in
{
  home.packages = [
    tresorit-fhs
    tresorit-launcher
  ];

  xdg = {
    dataFile."applications/tresorit-fhs.desktop".source = tresorit-desktop-entry;
    configFile."autostart/tresorit-fhs.desktop".source = tresorit-desktop-entry;
  };
}
