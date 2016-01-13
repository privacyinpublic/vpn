#!/usr/bin/env bash

DNS_SERVER="{{ nameserver1 }} {{ nameserver2 }}"

iptables -F

# Allow loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Allow local DHCP broadcast
iptables -A OUTPUT -d 255.255.255.255 -j ACCEPT
iptables -A INPUT -s 255.255.255.255 -j ACCEPT

# Allow over VPN
iptables -A INPUT -i tun+ -j ACCEPT
iptables -A OUTPUT -o tun+ -j ACCEPT

# SSH
iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport ssh -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -p tcp --sport 22 -j ACCEPT

# Deluge web
iptables -A INPUT -s 10.0.0.0/8 -p tcp --dport 8112 -j ACCEPT
iptables -A OUTPUT -d 10.0.0.0/8 -p tcp --sport 8112 -j ACCEPT

# Allow connections to VPN over ETH+
iptables -A OUTPUT -p udp --dport 1194 -j ACCEPT
iptables -A INPUT -p udp --sport 1194 -j ACCEPT

# Allow connections to VPN
iptables -A INPUT -s us-california.privateinternetaccess.com -j ACCEPT
iptables -A OUTPUT -d us-california.privateinternetaccess.com -j ACCEPT

# Allow only PIA DNS Servers
for ip in $DNS_SERVER
do
    echo "Allowing DNS lookups (tcp, udp port 53) to server '$ip'"
    iptables -A OUTPUT -p udp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A OUTPUT -p tcp -d $ip --dport 53 -m state --state NEW,ESTABLISHED -j ACCEPT
    iptables -A INPUT  -p udp -s $ip --sport 53 -m state --state ESTABLISHED -j ACCEPT
    iptables -A INPUT  -p tcp -s $ip --sport 53 -m state --state ESTABLISHED -j ACCEPT
done

#Default Deny
iptables -A INPUT -j DROP
iptables -A OUTPUT -j DROP
