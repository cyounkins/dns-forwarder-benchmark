{ config, lib, pkgs, ... }:
{
  services.unbound.settings = {
    forward-zone = [
      {
        name = ".";
        forward-addr = [
          "8.8.8.8"
        ];
      }
    ];
  };
}
