{ config, lib, pkgs, ... }:
{
  services.unbound.enable = true;
  services.unbound.resolveLocalQueries = false;
  services.unbound.settings = {
    server = {
      interface = [ "127.0.0.1" ];
      access-control = [ "127.0.0.1/24 allow" ];
      verbosity = 0;
    };
    remote-control.control-enable = false;
  };
}
