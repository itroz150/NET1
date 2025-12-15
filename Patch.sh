#!/bin/bash

# Script pour créer une tarball avec les configurations NET1 patchées
# Usage: bash create_net1_configs.sh

# Créer un répertoire temporaire
mkdir -p net1_configs

# 1. backbone-router (patché - ajout ip_forward)
cat > net1_configs/backbone-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 203.0.113.4
    netmask 255.255.255.254

auto eth1
iface eth1 inet static
    address 203.0.113.2
    netmask 255.255.255.254

post-up echo 1 > /proc/sys/net/ipv4/ip_forward

post-up ip route add 198.51.100.0/24 via 203.0.113.5
post-up ip route add 192.0.2.0/24 via 203.0.113.5
post-up ip route add 203.0.113.128/25 via 203.0.113.3
EOF

# 2. daisy-tcom-router (patché - ajout ip_forward)
cat > net1_configs/daisy-tcom-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 203.0.113.5
    netmask 255.255.255.254
    gateway 203.0.113.4

auto eth1
iface eth1 inet static
    address 198.51.100.121
    netmask 255.255.255.248

auto eth2
iface eth2 inet static
    address 192.0.2.129
    netmask 255.255.255.128

post-up echo 1 > /proc/sys/net/ipv4/ip_forward
EOF

# 3. lotus-tcom-router (patché - ajout ip_forward)
cat > net1_configs/lotus-tcom-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 203.0.113.3
    netmask 255.255.255.254
    gateway 203.0.113.2

auto eth1
iface eth1 inet static
    address 203.0.113.129
    netmask 255.255.255.248

post-up echo 1 > /proc/sys/net/ipv4/ip_forward

post-up dnsmasq --interface=eth1 --bind-interfaces --dhcp-range=203.0.113.130,203.0.113.134,12h --dhcp-option=3,203.0.113.129
EOF

# 4. clover-corp-router (patché - ajout ip_forward + correction firewall)
cat > net1_configs/clover-corp-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 198.51.100.123
    netmask 255.255.255.248
    gateway 198.51.100.121

auto eth1
iface eth1 inet static
    address 10.101.50.1
    netmask 255.255.255.0

auto eth2
iface eth2 inet static
    address 10.102.10.1
    netmask 255.255.255.0

post-up echo 1 > /proc/sys/net/ipv4/ip_forward

post-up dnsmasq --interface=eth2 --bind-interfaces --dhcp-range=10.102.10.100,10.102.10.200,12h --dhcp-option=3,10.102.10.1

post-up iptables -P INPUT DROP
post-up iptables -P FORWARD DROP
post-up iptables -P OUTPUT ACCEPT

post-up iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT
post-up iptables -A INPUT -p icmp -j ACCEPT
post-up iptables -A INPUT -i lo -j ACCEPT

post-up iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

post-up iptables -A FORWARD -i eth2 -o eth0 -j ACCEPT
post-up iptables -A FORWARD -i eth1 -o eth0 -j ACCEPT

post-up iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -j ACCEPT

post-up iptables -A FORWARD -i eth1 -o eth2 -j DROP

post-up iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.101.50.10

post-up iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 198.51.100.123
EOF

# 5. rhodes-corp-router (patché - ajout ip_forward)
cat > net1_configs/rhodes-corp-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 192.0.2.150
    netmask 255.255.255.128
    gateway 192.0.2.129

auto eth1
iface eth1 inet static
    address 10.128.100.1
    netmask 255.255.255.0

post-up echo 1 > /proc/sys/net/ipv4/ip_forward

post-up iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.128.100.10

post-up iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 192.0.2.150
EOF

# 6. lotus-home-box (patché - ajout ip_forward)
cat > net1_configs/lotus-home-box.txt << 'EOF'
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.168.42.1
    netmask 255.255.255.0

post-up echo 1 > /proc/sys/net/ipv4/ip_forward

post-up dnsmasq --interface=eth1 --bind-interfaces --dhcp-range=192.168.42.100,192.168.42.200,12h --dhcp-option=3,192.168.42.1

post-up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF

# Créer la tarball
tar -czf net1_configs.tar.gz net1_configs/

# Nettoyer
rm -rf net1_configs/

echo "✅ Tarball créée: net1_configs.tar.gz"
echo ""
echo "📦 Fichiers patchés inclus:"
echo "  - backbone-router.txt (+ ip_forward)"
echo "  - daisy-tcom-router.txt (+ ip_forward)"
echo "  - lotus-tcom-router.txt (+ ip_forward)"
echo "  - clover-corp-router.txt (+ ip_forward + firewall corrigé)"
echo "  - rhodes-corp-router.txt (+ ip_forward)"
echo "  - lotus-home-box.txt (+ ip_forward)"
echo ""
echo "ℹ️  Les autres fichiers (srv-*, workstation-*, home-pc) n'ont pas été modifiés"
echo "   et ne sont donc pas inclus dans cette tarball."
echo ""
echo "✨ Patches appliqués:"
echo "  ✅ Routage IP activé (ip_forward) sur tous les routeurs"
echo "  ✅ Firewall Clover Corp corrigé (ordre des règles + loopback)"
echo ""
echo "Pour extraire:"
echo "  tar -xzf net1_configs.tar.gz"
