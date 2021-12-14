{ config, lib, pkgs, ... }:
{
  imports = [
    ./_kresd_common.nix
  ];
  services.kresd.extraConfig = 
    ''
    cache.size = 60*MB
    policy.add(policy.all(policy.TLS_FORWARD({{'8.8.8.8', hostname='dns.google'}})))
    trust_anchors.remove('.')
    '';
}
