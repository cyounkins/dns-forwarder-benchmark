Setup
-----

Usable on NixOS running as root.

Add `imports = [ ./dns.nix ];` to `/etc/nixos/configuration.nix`

Usage
-----

Start a shell with the needed dependencies using `nix-shell`. Run `./test.sh` to pull down the domain list and iterate through the tests.


Results
-------

Detailed at --TBD--

