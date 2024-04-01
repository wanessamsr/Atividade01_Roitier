#!/bin/bash
# Limpando todas as regras existentes
iptables -F
iptables -X

# Definindo a política padrão como DROP (bloquear tudo)
iptables -P INPUT DROP
iptables -P FORWARD DROP
iptables -P OUTPUT ACCEPT

# Permitindo conexões de loopback
iptables -A INPUT -i lo -j ACCEPT
iptables -A OUTPUT -o lo -j ACCEPT

# Permitindo tráfego DNS
iptables -A INPUT -p udp -s 53 -j ACCEPT
iptables -A OUTPUT -p udp -d 53 -j ACCEPT

# Permitindo tráfego DHCP
iptables -A INPUT -p udp -s 67 -j ACCEPT
iptables -A OUTPUT -p udp -d 67 -j ACCEPT

# Permitindo ping
iptables -A INPUT -p icmp --icmp-type echo-request -j ACCEPT
iptables -A OUTPUT -p icmp --icmp-type echo-reply -j ACCEPT

# Bloqueando HTTP e HTTPS
iptables -A INPUT -p tcp -d 80 -j DROP
iptables -A INPUT -p tcp -d 443 -j DROP

tail -f /dev/null
