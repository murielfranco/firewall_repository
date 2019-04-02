#!/bin/bash

set -e

echo "Initializing Firewall configuration..."

echo "Rules cleaned"
iptables -F

echo "Setting general logs"
iptables -A INPUT -j LOG

echo "Avoid DoS attacks"
iptables -A INPUT -p icmp --icmp-type echo-request -m limit --limit 1/s -j ACCEPT

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

echo "Allow Web Server on port 8500"
iptables -A FORWARD -p tcp --dport 8500 -j ACCEPT

echo "Block Web Server on port 8501"
iptables -A FORWARD -p tcp --dport 8501 -j DROP

echo "Firewall was successfully configured."
echo "Firewall started."

cd /Management/API/Scripts && sudo ./run_api.sh & # Run API
