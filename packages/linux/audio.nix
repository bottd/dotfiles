{pkgs, ...}:
{
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
  };
}
