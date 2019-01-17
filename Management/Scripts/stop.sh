#!/bin/bash

set -e

echo "Finalizando o Firewall"
rm -rf /var/lock/subsys/firewall

# Clean rules
iptables -F
iptables -X
iptables -t mangle -F


# Reset the policies. Now accept everything
iptables -P INPUT   ACCEPT
iptables -P OUTPUT  ACCEPT
iptables -P FORWARD ACCEPT