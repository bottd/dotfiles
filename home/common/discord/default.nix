#INFO: On mac, since this modifies signed discord, it now has to be allowed in security settings.
{pkgs, ...}: {
  home.packages = with pkgs; [
    (discord.override {
      # withOpenASAR = true;
      # Vencord produces an unopenable discord client on mac for me
      # withVencord = true;
    })
  ];
}
