#!/bin/bash
#Version 1.0 by George Dimitrov
#License The MIT License (MIT)
#Copyright 2019 George Dimitrov
#NOTE: Work in progress.

# TODO check script has ran before

wg genkey | tee server_private_key | wg pubkey > server_public_key

mkdir /etc/wireguard/

# TODO check if wg0 exists

touch /etc/wireguard/wg0.conf

server_key=$(cat server_private_key)
client_key=$(cat client_public_key)

echo "[Interface]
Address = 192.168.100.1/24
ListenPort = 5555
PostUp = iptables -A FORWARD -i wg0 -j ACCEPT; iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE; ip6tables -A FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
PostDown = iptables -D FORWARD -i wg0 -j ACCEPT; iptables -t nat -D POSTROUTING -o eth0 -j MASQUERADE; ip6tables -D FORWARD -i wg0 -j ACCEPT; ip6tables -t nat -D POSTROUTING -o eth0 -j MASQUERADE
PrivateKey = ${server_key}

[Peer]
PublicKey = ${client_key}
AllowedIPs = 192.168.100.2/32" > /etc/wireguard/wg0.conf

# TODO Check if values are in sysctl.conf add them if not

echo "net.ipv4.ip_forward = 1
net.ipv6.conf.all.forwarding = 1" >> /etc/sysctl.conf

sysctl -p

systemctl start wg-quick@wg0


