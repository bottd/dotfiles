{ config, inputs, pkgs, ... }:
let
  configuredKli = inputs.kli.lib.${pkgs.stdenv.hostPlatform.system}.mkConfiguredKli {
    inherit (config.programs.kli) extensions settings registries blessedNativeLibs dataDir sandbox;
  };
in
{
  imports = [ inputs.kli.homeManagerModules.default ];

  programs.kli = {
    enable = true;
    # buildLisp's runtime wrapper only sets LD_LIBRARY_PATH; macOS needs DYLD_LIBRARY_PATH.
    package = pkgs.symlinkJoin {
      name = "kli";
      paths = [ configuredKli ];
      nativeBuildInputs = [ pkgs.makeWrapper ];
      postBuild = ''
        rm "$out/bin/kli"
        makeWrapper ${configuredKli}/bin/kli "$out/bin/kli" \
          --prefix DYLD_LIBRARY_PATH : "${pkgs.openssl.out}/lib"
      '';
    };
  };

  home.file = {
    ".config/kli/settings.json".source =
      config.lib.meta.createSymlink "home/common/ai/kli/settings.json";
  };
}
