# Common font configuration for all systems
{pkgs, ...}: {
  fonts = {
    packages = with pkgs; [
      # Nerd fonts with custom symbols for dev environments
      (nerdfonts.override {
        fonts = [
          "JetBrainsMono"
          "FiraCode"
          "Meslo"
        ];
      })

      # Standard fonts
      inter
      noto-fonts
      noto-fonts-cjk
      noto-fonts-emoji

      # Programming fonts
      jetbrains-mono
      fira-code
      hack-font

      # Symbol fonts
      font-awesome
    ];

    # Font configuration
    fontconfig = {
      defaultFonts = {
        serif = ["Noto Serif" "Times New Roman"];
        sansSerif = ["Inter" "Noto Sans"];
        monospace = ["JetBrainsMono Nerd Font" "Fira Code"];
        emoji = ["Noto Color Emoji"];
      };

      # Enable subpixel rendering
      subpixel.rgba = "rgb";
    };
  };
}
