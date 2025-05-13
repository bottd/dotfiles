{
  hosts = {
    # NixOS configurations
    desktop = {
      system = "x86_64-linux";
      format = "nixos";
      username = "drakeb";
    };

    pocket = {
      system = "x86_64-linux";
      format = "nixos";
      username = "drakeb";
    };

    # Darwin configurations
    macbook = {
      system = "aarch64-darwin";
      format = "darwin";
      username = "drakebott";
    };

    # Home manager standalone configurations
    iris = {
      system = "aarch64-darwin";
      format = "home-manager";
      username = "drakebott";
    };
  };
}
