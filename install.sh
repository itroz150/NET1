#!/bin/bash

# Script pour créer une tarball avec toutes les configurations NET1
# Usage: bash create_net1_configs.sh

# Créer un répertoire temporaire
mkdir -p net1_configs

# 1. backbone-router
cat > net1_configs/backbone-router.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 203.0.113.4
    netmask 255.255.255.254

auto eth1
iface eth1 inet static
    address 203.0.113.2
    netmask 255.255.255.254

post-up ip route add 198.51.100.0/24 via 203.0.113.5
post-up ip route add 192.0.2.0/24 via 203.0.113.5
post-up ip route add 203.0.113.128/25 via 203.0.113.3
EOF

# 2. daisy-tcom-router
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
EOF

# 3. lotus-tcom-router
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

post-up dnsmasq --interface=eth1 --bind-interfaces --dhcp-range=203.0.113.130,203.0.113.134,12h --dhcp-option=3,203.0.113.129
EOF

# 4. clover-corp-router
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

post-up dnsmasq --interface=eth2 --bind-interfaces --dhcp-range=10.102.10.100,10.102.10.200,12h --dhcp-option=3,10.102.10.1

post-up iptables -P INPUT DROP
post-up iptables -P FORWARD DROP
post-up iptables -P OUTPUT ACCEPT

post-up iptables -A INPUT -p icmp -j ACCEPT
post-up iptables -A INPUT -m state --state RELATED,ESTABLISHED -j ACCEPT

post-up iptables -A FORWARD -m state --state RELATED,ESTABLISHED -j ACCEPT

post-up iptables -A FORWARD -o eth0 -j ACCEPT

post-up iptables -A FORWARD -i eth0 -o eth1 -p tcp --dport 80 -j ACCEPT

post-up iptables -A FORWARD -i eth1 -o eth2 -m state --state NEW -j DROP

post-up iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.101.50.10

post-up iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 198.51.100.123
EOF

# 5. rhodes-corp-router
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

post-up iptables -t nat -A PREROUTING -i eth0 -p tcp --dport 80 -j DNAT --to-destination 10.128.100.10

post-up iptables -t nat -A POSTROUTING -o eth0 -j SNAT --to-source 192.0.2.150
EOF

# 6. lotus-home-box
cat > net1_configs/lotus-home-box.txt << 'EOF'
auto eth0
iface eth0 inet dhcp

auto eth1
iface eth1 inet static
    address 192.168.42.1
    netmask 255.255.255.0

post-up dnsmasq --interface=eth1 --bind-interfaces --dhcp-range=192.168.42.100,192.168.42.200,12h --dhcp-option=3,192.168.42.1

post-up iptables -t nat -A POSTROUTING -o eth0 -j MASQUERADE
EOF

# 7. srv-website
cat > net1_configs/srv-website.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 10.101.50.10
    netmask 255.255.255.0
    gateway 10.101.50.1
EOF

# 8. srv-app
cat > net1_configs/srv-app.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 10.101.50.20
    netmask 255.255.255.0
    gateway 10.101.50.1
EOF

# 9. rhodes-corp-website
cat > net1_configs/rhodes-corp-website.txt << 'EOF'
auto eth0
iface eth0 inet static
    address 10.128.100.10
    netmask 255.255.255.0
    gateway 10.128.100.1
EOF

# 10. workstation-1
cat > net1_configs/workstation-1.txt << 'EOF'
auto eth0
iface eth0 inet dhcp
EOF

# 11. workstation-2
cat > net1_configs/workstation-2.txt << 'EOF'
auto eth0
iface eth0 inet dhcp
EOF

# 12. home-pc
cat > net1_configs/home-pc.txt << 'EOF'
auto eth0
iface eth0 inet dhcp
EOF

# Créer la tarball
tar -czf net1_configs.tar.gz net1_configs/

# Nettoyer
rm -rf net1_configs/

echo "✅ Tarball créée: net1_configs.tar.gz"
echo ""
echo "Pour extraire:"
echo "  tar -xzf net1_configs.tar.gz"
echo ""
echo "Les fichiers seront dans le dossier net1_configs/"
