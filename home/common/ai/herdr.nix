{
  config,
  inputs,
  pkgs,
  ...
}:
{
  home.packages = [ inputs.herdr.packages.${pkgs.stdenv.hostPlatform.system}.default ];

  # Manage machine membership in Nix; Herdr stores the selected machine separately.
  home.file."${config.xdg.stateHome}/herdr/client/endpoints.json".text = builtins.toJSON {
    version = 1;
    ssh = [
      {
        id = builtins.substring 0 32 (builtins.hashString "sha256" "herdr-loge");
        label = "Loge";
        target = "herdr@loge";
        session = "default";
        enabled = true;
      }
    ];
  };
}
