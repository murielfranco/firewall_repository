#!/bin/bash

set -e

echo "Initializing Firewall configuration..."

echo "Rules cleaned"
iptables -F

echo "Setting general logs"
iptables -A INPUT -j LOG

echo "Avoid DoS attacks"
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

echo "Block pings"
iptables -A INPUT -p icmp --icmp-type echo-request -j DROP

echo "Security Policies"
echo 0 > /proc/sys/net/ipv4/conf/all/accept_source_route # Avoid fake packets
echo 0 > /proc/sys/net/ipv4/conf/all/accept_redirects # Perigo de descobrimento de rotas de roteamento (desativar em roteador)
echo 1 > /proc/sys/net/ipv4/icmp_echo_ignore_broadcasts # Reduce DoS risks
echo 1 > /proc/sys/net/ipv4/tcp_syncookies # Only starts the connection when receives a confirmation.
echo 1 > /proc/sys/net/ipv4/conf/default/rp_filter # Firewall responses only the network device that received the packet
iptables -A INPUT -m state --state INVALID -j DROP # Delete all invalid packets

# Allow SSH acess and limitate the number of try to access (in a period equal to 4 minutes)
echo "Allowing SSH"
iptables -I INPUT -p tcp --dport 22 -i eth0 -m state --state NEW -m recent --update --seconds 60 --hitcount 4 -j DROP
iptables -A INPUT -p tcp --dport 22 -j ACCEPT
iptables -A INPUT -p udp --dport 22 -j ACCEPT


echo "Allowing Apache"
iptables -A INPUT -p tcp --dport 80 -j ACCEPT

echo "Firewall was configured with sucess."
echo "Firewall started."

sudo ./run_api.sh # Run API
