{ ...
}: {
  services.darkman = {
    enable = true;

    settings = {
      # Chicago coordinates
      lat = 41.9;
      lng = -87.6;
      dbusserver = true;
      portal = true;
    };

    darkModeScripts = {
      theme = builtins.readFile ./dark-theme.bb;
    };

    lightModeScripts = {
      theme = builtins.readFile ./light-theme.bb;
    };
  };

}










