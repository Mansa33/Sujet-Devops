#!/bin/bash
set -e
apt-get update -y
apt-get install -y ca-certificates curl gnupg git
install -m 0755 -d /etc/apt/keyrings
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | gpg --dearmor -o /etc/apt/keyrings/docker.gpg
chmod a+r /etc/apt/keyrings/docker.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/docker.gpg] https://download.docker.com/linux/ubuntu $(. /etc/os-release && echo "$VERSION_CODENAME") stable" | tee /etc/apt/sources.list.d/docker.list
apt-get update -y
apt-get install -y docker-ce docker-ce-cli containerd.io docker-compose-plugin
usermod -aG docker azureadmin
cd /home/azureadmin
git clone https://github.com/Mansa33/Sujet-Devops.git
chown -R azureadmin:azureadmin Sujet-Devops
cd /home/azureadmin/Sujet-Devops
docker compose -f docker-compose-monitoring.yml pull
docker compose -f app/docker-compose.yml pull
docker compose -f app/docker-compose.yml up -d --build
sleep 5
docker compose -f docker-compose-monitoring.yml up -d
echo "Setup complete at $(date)" > /home/azureadmin/setup.log
