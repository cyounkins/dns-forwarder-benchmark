#! /usr/bin/env python

import statistics
import sys
import time

import dns.resolver


def main():
    if len(sys.argv) != 3:
        print(f'{sys.argv[0]} <input_filename> <dns_server_ip>')
        sys.exit(-1)

    input_filename = sys.argv[1]
    dns_server_ip = sys.argv[2]

    with open(input_filename, 'r') as f:
        lines = f.readlines()

    resolver = dns.resolver.Resolver(configure=False)
    resolver.nameservers = [dns_server_ip]

    times = []

    for line in lines:
        line = line.strip()
        t0 = time.time()
        try:
            resolver.resolve(line)
        except dns.exception.DNSException as e:
            print(f'Unable to resolve {line}: {e}')
        delta = time.time() - t0
        times.append(delta)

    print(statistics.median(times) * 1000)


if __name__ == '__main__':
    main()
