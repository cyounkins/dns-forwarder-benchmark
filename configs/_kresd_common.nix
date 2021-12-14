{ config, lib, pkgs, ... }:
{
  services.kresd.enable = true;
  fileSystems."/var/cache/knot-resolver" = { 
    device = "tmpfs";
    fsType = "tmpfs";
    options = [ "defaults" "size=128M" "mode=777" ];
  };
}
