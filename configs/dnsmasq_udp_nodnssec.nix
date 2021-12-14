{ config, lib, pkgs, ... }:
{
  imports = [
    ./_dnsmasq_common.nix
  ];
  services.dnsmasq.extraConfig = ''
    no-resolv
    clear-on-reload
  '';
}
