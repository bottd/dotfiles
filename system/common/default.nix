{ pkgs
, ...
}:
let
  isLinux = pkgs.stdenv.hostPlatform.isLinux;
  isDarwin = pkgs.stdenv.hostPlatform.isDarwin;
in
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
    };

    gc =
      if isLinux
      then {
        automatic = true;
        dates = "weekly";
        options = "--delete-older-than 30d";
      }
      else {
        automatic = true;
        interval = {
          Weekday = 0;
          Hour = 2;
          Minute = 0;
        };
      };
  };

  time.timeZone = "America/Chicago";

  imports =
    if isLinux
    then [
      ./linux
    ]
    else if isDarwin
    then [
      ./darwin
    ]
    else [ ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
}
