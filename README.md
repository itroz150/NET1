#!/bin/bash
set -e

echo "=== SCRIPT ULTRA CLEAN GNS3 + Docker (Debian) ==="

# -----------------------------
# 1️⃣ Supprimer anciennes installations pip
echo "[1/10] Suppression des binaires pip"
rm -f ~/.local/bin/gns3 ~/.local/bin/gns3server
sudo rm -f /usr/local/bin/gns3 /usr/local/bin/gns3server

echo "[2/10] Désinstallation pip (silencieuse)"
pip3 uninstall -y gns3-gui gns3-server gns3 || true

# -----------------------------
# 2️⃣ Nettoyer /etc/apt/sources.list pour GNS3
echo "[3/10] Configuration des dépôts Debian"
CODENAME=$(lsb_release -cs)
sudo cp /etc/apt/sources.list /etc/apt/sources.list.bak
sudo tee /etc/apt/sources.list > /dev/null <<EOL
deb http://deb.debian.org/debian $CODENAME main contrib non-free-firmware
deb http://deb.debian.org/debian $CODENAME-updates main contrib non-free-firmware
deb http://security.debian.org/debian-security $CODENAME-security main contrib non-free-firmware
EOL

# -----------------------------
# 3️⃣ Mise à jour APT
echo "[4/10] Mise à jour des dépôts"
sudo apt update

# -----------------------------
# 4️⃣ Installer dépendances
echo "[5/10] Installation des dépendances et utilitaires"
sudo apt install -y \
python3 python3-pip python3-setuptools python3-pyqt5 python3-pyqt5.qtsvg \
qemu-kvm libvirt-daemon-system libvirt-clients bridge-utils \
wireshark git curl apt-transport-https ca-certificates gnupg lsb-release

# -----------------------------
# 5️⃣ Installer Docker (officiel)
echo "[6/10] Installation Docker"
sudo mkdir -p /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/debian/gpg | sudo gpg --dearmor -o /etc/apt/keyrings/docker.gpg
echo \
"deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] \
https://download.docker.com/linux/debian $CODENAME stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
sudo apt update
sudo apt install -y docker-ce docker-ce-cli containerd.io docker-buildx-plugin docker-compose-plugin
sudo systemctl enable docker
sudo systemctl start docker

# -----------------------------
# 6️⃣ Installer GNS3 via APT
echo "[7/10] Installation GNS3 stable"
sudo apt install -y gns3-gui gns3-server

# -----------------------------
# 7️⃣ Ajouter l'utilisateur aux groupes
echo "[8/10] Configuration des groupes"
sudo usermod -aG docker,libvirt,kvm,wireshark "$USER"

# -----------------------------
# 8️⃣ Permissions Wireshark
echo "[9/10] Autoriser Wireshark sans root"
sudo dpkg-reconfigure wireshark-common || true

# -----------------------------
# 9️⃣ Nettoyage final
echo "[10/10] Vérifications"
echo "gns3  -> $(which gns3 || echo 'NOT FOUND')"
echo "gns3server -> $(which gns3server || echo 'NOT FOUND')"
echo "docker -> $(which docker || echo 'NOT FOUND')"

echo ""
echo "✅ SCRIPT TERMINÉ"
echo "⚠️ Déconnexion et reconnexion obligatoires pour appliquer les groupes"
echo "Après reconnexion, tester :"
echo "  docker ps"
echo "  gns3server"
echo "  gns3"
echo "Dans GNS3 GUI : Edit → Preferences → Docker → Test"
echo "======================================"
