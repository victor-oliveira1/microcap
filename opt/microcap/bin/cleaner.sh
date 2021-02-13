#!/bin/sh
# Clean iptables expired entries
# MicroCap <victor.oliveira@gmx.com>

iptables --line-numbers -t mangle -n -L PREROUTING | \
grep $(date +%s | head -c 8) | \
while read LINE; do
    NUMBER=$(echo "${LINE}"|cut -d" " -f1)
    iptables -t mangle -D PREROUTING "${NUMBER}"
done