{ pkgs, ... }: {
  programs = {
    direnv = {
      enable = true;
      package = pkgs.direnv.overrideAttrs (_old: {
        buildPhase = ''
          go build -ldflags "-X main.bashPath=${pkgs.bash}/bin/bash" -o direnv
        '';
      });
      enableBashIntegration = true;
      enableZshIntegration = true;
      nix-direnv.enable = true;
      silent = true;
    };
  };
}
