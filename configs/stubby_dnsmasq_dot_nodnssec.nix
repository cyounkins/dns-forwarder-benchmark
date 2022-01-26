{ config, lib, pkgs, ... }:
{
  services.stubby.enable = true;
  services.stubby.listenAddresses = [ "127.0.0.1@1053" ];
  services.stubby.upstreamServers = ''
    - address_data: 8.8.8.8
      tls_auth_name: "dns.google"
  '';

  services.dnsmasq.enable = true;
  services.dnsmasq.resolveLocalQueries = false;
  services.dnsmasq.servers = [
    "127.0.0.1#1053"
  ];
  services.dnsmasq.extraConfig = ''
    no-resolv
    clear-on-reload
  '';
}
