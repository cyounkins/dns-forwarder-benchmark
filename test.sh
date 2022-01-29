#! /usr/bin/env bash

#set -x

SCRIPT_DIR="$( cd -- "$( dirname -- "${BASH_SOURCE[0]}" )" &> /dev/null && pwd )"
LOG_DIR=$SCRIPT_DIR/logs/$(date +%s)
UPSTREAM_IP="8.8.8.8"

function setup {
  echo "Creating log dir..."
  mkdir -p "$LOG_DIR"
  
  if [ ! -f "my-domains.txt" ]; then
    python make-domains-list.py 2000 > my-domains.txt
  fi
}

function switch_dns {
  echo "Updating local DNS server to $1..."
  rm /etc/nixos/dns.nix
  ln -s "$SCRIPT_DIR/configs/$1" "/etc/nixos/dns.nix"
  nixos-rebuild switch
}

function print_unbound_config {
  unbound -V
  echo "Unbound config at /etc/unbound/unbound.conf:"
  echo "---------------------------"
  cat /etc/unbound/unbound.conf
  echo "---------------------------"
}

function print_stubby_config {
  stubby -V
  CONF=$(ps aux | grep -oP '(?<= -C )(/nix.*-stubby.yml)')
  echo "stubby config at $CONF"
  echo "---------------------------"
  cat "$CONF"
  echo "---------------------------"
}

function print_dnsmasq_config {
  PROG=$(ps aux | grep -oP '(/nix[^ ]*bin/dnsmasq)')
  $PROG -v
  CONF=$(ps aux | grep -oP '(?<= -C )(/nix.*-dnsmasq.conf)')
  echo "dnsmasq config at $CONF"
  echo "---------------------------"
  cat "$CONF"
  echo "---------------------------"
}

function print_kresd_config {
  CONF=$(ps aux | grep -oP '(?<= -c )(/nix[^ ]*-kresd.conf)')
  echo "kresd config at $CONF"
  echo "---------------------------"
  cat "$CONF"
  echo "---------------------------"
}

function wait_for_zero_connections_to_upstream {
  echo "Waiting for zero connections to upstream"
  CONNECTIONS=1
  while [ $CONNECTIONS -gt 0 ]; do
    CONNECTIONS=$(ss -an4 | grep -F "$UPSTREAM_IP" | wc -l)
    sleep 1
  done
}

function print_tcp_connections_opened {
  echo "TCP connections opened to upstream:"
  tcpdump -r "$1" "dst $UPSTREAM_IP and tcp[tcpflags] == tcp-syn" | wc -l
}

function benchmark_target {
  echo "Running benchmark against $1"
  python "$SCRIPT_DIR/bench.py" "$SCRIPT_DIR/my-domains.txt" "$1"
}

function test_unbound {
  switch_dns "$1"
  systemctl restart unbound
  print_unbound_config
  wait_for_zero_connections_to_upstream
  PCAP_FILE="$LOG_DIR/$1.pcap"
  tcpdump -i eth0 -U -v -w "$PCAP_FILE" host "$UPSTREAM_IP" 2>&1 &
  TCPDUMP_PID=$!
  sleep 1
  benchmark_target "127.0.0.1"
  sleep 1
  kill $TCPDUMP_PID
  print_tcp_connections_opened "$PCAP_FILE"
  echo ""
}

function test_dnsmasq {
  switch_dns "$1"
  systemctl restart dnsmasq
  print_dnsmasq_config
  wait_for_zero_connections_to_upstream
  PCAP_FILE="$LOG_DIR/$1.pcap"
  tcpdump -i eth0 -U -v -w "$PCAP_FILE" host "$UPSTREAM_IP" 2>&1 &
  TCPDUMP_PID=$!
  sleep 1
  benchmark_target "127.0.0.1"
  sleep 1
  kill $TCPDUMP_PID
  print_tcp_connections_opened "$PCAP_FILE"
  dig +short chaos txt hits.bind @127.0.0.1
  dig +short chaos txt misses.bind @127.0.0.1
  echo ""
}

function test_stubby_dnsmasq {
  switch_dns "$1"
  systemctl restart stubby
  systemctl restart dnsmasq
  print_stubby_config
  print_dnsmasq_config
  wait_for_zero_connections_to_upstream
  PCAP_FILE="$LOG_DIR/$1.pcap"
  tcpdump -i eth0 -U -v -w "$PCAP_FILE" host "$UPSTREAM_IP" 2>&1 &
  TCPDUMP_PID=$!
  sleep 1
  benchmark_target "127.0.0.1"
  sleep 1
  kill $TCPDUMP_PID
  print_tcp_connections_opened "$PCAP_FILE"
  dig +short chaos txt hits.bind @127.0.0.1
  dig +short chaos txt misses.bind @127.0.0.1
  echo ""
}

function test_kresd {
  switch_dns "$1"
  systemctl stop kresd@1.service
  rm /var/cache/knot-resolver/*
  systemctl start kresd@1.service
  print_kresd_config
  wait_for_zero_connections_to_upstream
  PCAP_FILE="$LOG_DIR/$1.pcap"
  tcpdump -i eth0 -U -v -w "$PCAP_FILE" host "$UPSTREAM_IP" 2>&1 &
  TCPDUMP_PID=$!
  sleep 1
  benchmark_target "127.0.0.1"
  sleep 1
  kill $TCPDUMP_PID
  print_tcp_connections_opened "$PCAP_FILE"
  echo ""
}

setup

switch_dns "control.nix"
wait_for_zero_connections_to_upstream
PCAP_FILE="$LOG_DIR/control.pcap"
tcpdump -i eth0 -U -v -w "$PCAP_FILE" host "$UPSTREAM_IP" 2>&1 &
TCPDUMP_PID=$!
sleep 1
benchmark_target "$UPSTREAM_IP"
sleep 1
kill $TCPDUMP_PID
print_tcp_connections_opened "$PCAP_FILE"

cd configs || exit

test_unbound "unbound_udp_nodnssec.nix"
test_unbound "unbound_dot_nodnssec.nix"

test_kresd "kresd_udp_nodnssec.nix"
test_kresd "kresd_dot_nodnssec.nix"

test_dnsmasq "dnsmasq_udp_nodnssec.nix"
test_stubby_dnsmasq "stubby_dnsmasq_dot_nodnssec.nix"

#for config in kresd*; do
#  test_kresd "$config"
#done

#for config in dnsmasq*; do
#  test_dnsmasq "$config"
#done

#for config in unbound*; do
#  test_unbound "$config"
#done

