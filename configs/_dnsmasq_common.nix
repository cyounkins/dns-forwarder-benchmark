{ config, lib, pkgs, ... }:
{
  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = false;
  services.dnsmasq.servers = [
    "8.8.8.8"
  ];
}
