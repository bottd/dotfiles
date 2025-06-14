{ pkgs
, ...
}:
{
  nix = {
    settings = {
      experimental-features = [ "nix-command" "flakes" ];
      warn-dirty = false;
      auto-optimise-store = true;
    };

    gc = {
      automatic = true;
      interval = {
        Weekday = 0;
        Hour = 2;
        Minute = 0;
      };
    };
  };

  time.timeZone = "America/Chicago";

  imports = [
    ./darwin
  ];

  environment.systemPackages = with pkgs; [
    git
    curl
    wget
  ];
}
