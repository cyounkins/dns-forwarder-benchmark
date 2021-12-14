{ config, lib, pkgs, ... }:
{
  imports = [ 
    ./_unbound_common.nix
    ./_unbound_dot.nix 
  ];
  services.unbound.enableRootTrustAnchor = false;
}
