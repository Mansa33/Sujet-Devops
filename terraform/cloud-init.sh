#!/bin/bash
# ============================================================
# Script cloud-init — s'execute automatiquement au premier
# demarrage de la VM cree par Terraform
# Installe Docker et demarre toute la stack Althea
# ============================================================
set -e  # Arrete le script en cas d'erreur

# Mise a jour du systeme et installation des dependances
apt-get update -y
apt-get install -y ca-certificates curl gnupg git

# Ajout du depot officiel Docker pour Ubuntu
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list

# Installation de Docker Engine et Docker Compose
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin

# Ajout de l'utilisateur au groupe docker (sans besoin de sudo)
usermod -aG docker azureadmin

# Clone du repo GitHub contenant toute la configuration
cd /home/azureadmin
git clone https://github.com/Mansa33/Sujet-Devops.git
chown -R azureadmin:azureadmin Sujet-Devops

cd /home/azureadmin/Sujet-Devops

# Pre-telechargement de toutes les images Docker
# Fait pendant le cloud-init pour eviter les timeouts au demarrage
docker compose -f docker-compose-monitoring.yml pull
docker compose -f app/docker-compose.yml pull

# Demarrage de l'app EN PREMIER — cree le reseau Docker althea-net
# necessaire pour le stack monitoring
docker compose -f app/docker-compose.yml up -d --build
sleep 5

# Demarrage du monitoring APRES l'app (depend du reseau althea-net)
docker compose -f docker-compose-monitoring.yml up -d

# Confirmation de fin d'installation avec horodatage
echo "Setup complete at $(date)" > /home/azureadmin/setup.log
