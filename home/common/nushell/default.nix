{
  config,
  pkgs,
  neorgWorkspace,
  ...
}: {
  programs.nushell = {
    enable = true;
    configFile.source = ./config.nu;
    envFile.source = ./env.nu;
    extraEnv =
      #nu
      ''
        $env.NEORG_WORKSPACE = "${neorgWorkspace}"
        $env.NEORG_WORKSPACE_PATH = "~/${neorgWorkspace}"
      '';
  };

  programs.carapace = {
    enable = true;
    enableNushellIntegration = true;
  };

  home.file = {
    ".config/nushell/themes/light.nu" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/nushell/nu_scripts/refs/heads/main/themes/nu-themes/catppuccin-latte.nu";
        sha256 = "sha256-ZTj9LieBU7SytSJfWnJN4II67+4OSOhL2NE5U/Em+xE=";
      };
    };
    ".config/nushell/themes/dark.nu" = {
      source = pkgs.fetchurl {
        url = "https://raw.githubusercontent.com/catppuccin/hyprland/refs/tags/v1.3/themes/latte.conf";
        sha256 = "sha256-kdflq+y1F8jQI1oFtl6Of31VTW7YdLvSaulPuve7Rz0=";
      };
    };
    ".config/nushell/scripts" = {
      source = ./scripts;
      recursive = true;
    };
  };

  home.packages = with pkgs; [
    neofetch
  ];
}
