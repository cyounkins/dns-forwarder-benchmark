{ config, lib, pkgs, ... }:
{
  imports = [
    ./_dnsmasq_common.nix
  ];
  services.dnsmasq.extraConfig = ''
    no-resolv
    clear-on-reload
    dnssec
    trust-anchor=.,20326,8,2,E06D44B80B8F1D39A95C0B0D7C65D08458E880409BBC683457104237C7F8EC8D
  '';
}
