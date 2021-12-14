#! /usr/bin/env python

import csv
import io
import os.path
import re
import statistics
import sys
import time
import zipfile

import dns.resolver
import requests

RESOLVER = '8.8.8.8'
NUM_DOMAINS = 1000

def main():
    if not os.path.isfile('top-1m.csv'):
        # See https://s3-us-west-1.amazonaws.com/umbrella-static/index.html
        request = requests.get('https://s3-us-west-1.amazonaws.com/umbrella-static/top-1m.csv.zip')
        zip = zipfile.ZipFile(io.BytesIO(request.content))
        zip.extract('top-1m.csv')

    unfiltered_domains = []
    with open('top-1m.csv', 'r') as f:
        reader = csv.reader(f)
        for row in reader:
            unfiltered_domains.append(row[1])

    resolver = dns.resolver.Resolver(configure=False)
    resolver.nameservers = [RESOLVER]

    filtered_domains = []
    for domain in unfiltered_domains:
        if domain.count('.') != 1:
            continue
        try:
            resolver.resolve(domain)
            filtered_domains.append(domain)
            if len(filtered_domains) >= NUM_DOMAINS:
                break
        except dns.exception.DNSException as e:
            pass

    for domain in filtered_domains:
        print(domain)


if __name__ == '__main__':
    main()

