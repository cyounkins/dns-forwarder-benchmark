{ config, lib, pkgs, ... }:
{
  imports = [
    ./_unbound_common.nix
    ./_unbound_udp.nix
  ];
  services.unbound.enableRootTrustAnchor = true;
}
