#!/usr/bin/env bash
set -e
echo "Installing IPtables..."

# Install IPTables
sudo DEBIAN_FRONTEND=noninteractive apt-get install iptables --yes

cd API/rfw-master
sudo python setup.py install
