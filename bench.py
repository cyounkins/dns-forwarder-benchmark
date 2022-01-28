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

    print("Mean:", round(statistics.mean(times) * 1000, 1))
    print("Median:", round(statistics.median(times) * 1000, 1))

    percentiles = statistics.quantiles(times, n=100)
    assert(len(percentiles) == 99)
    print("P90:", round(percentiles[90 - 2] * 1000, 1))
    print("P95:", round(percentiles[95 - 2] * 1000, 1))


if __name__ == '__main__':
    main()
