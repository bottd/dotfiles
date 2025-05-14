# Automatically set hostname based on the host parameter
{host, ...}: {
  networking.hostName = host;
}
