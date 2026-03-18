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

cat > /home/azureadmin/start-services.sh << 'SCRIPT'
#!/bin/bash
until docker info > /dev/null 2>&1; do
  echo "Waiting for Docker..."
  sleep 3
done

cd /home/azureadmin/Sujet-Devops
docker compose -f docker-compose-monitoring.yml pull
docker compose -f app/docker-compose.yml pull
docker compose -f docker-compose-monitoring.yml up -d
sleep 15
docker compose -f app/docker-compose.yml up -d --build
echo "Setup complete at $(date)" > /home/azureadmin/setup.log
SCRIPT

chmod +x /home/azureadmin/start-services.sh

cat > /etc/systemd/system/althea-start.service << 'SERVICE'
[Unit]
Description=Start Althea Services
After=docker.service network-online.target
Wants=docker.service network-online.target

[Service]
Type=oneshot
ExecStart=/home/azureadmin/start-services.sh
RemainAfterExit=yes
TimeoutStartSec=600
User=root
StandardOutput=journal
StandardError=journal

[Install]
WantedBy=multi-user.target
SERVICE

systemctl daemon-reload
systemctl enable althea-start.service
echo "Cloud-init done at $(date)" > /home/azureadmin/cloudinit.log
