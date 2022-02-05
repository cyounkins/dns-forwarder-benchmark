Setup
-----

Usable on NixOS running as root.

Add `imports = [ ./dns.nix ];` to `/etc/nixos/configuration.nix`


Usage
-----

Start a shell with the needed dependencies using `nix-shell`. Run `./test.sh` to pull down the domain list and iterate through the tests.


Results
-------

My tests were ran on an idle Raspberry Pi 3B with 1GB RAM on wired Ethernet.

DNSSEC: https://cyounkins.medium.com/costs-and-benefits-of-local-dnssec-validation-53c72ca9059b
DNS-over-TLS: https://cyounkins.medium.com/performance-of-dns-over-tls-4f4b8f938bc

