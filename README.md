🏥 Althea DevOps — Infrastructure de Monitoring
Projet DevOps déployé sur Microsoft Azure (France Central) dans le cadre d'un hébergement conforme HDS (Hébergement de Données de Santé).

🏗️ Architecture
Infrastructure Cloud

Provider : Microsoft Azure — Région France Central
VM : Ubuntu 24.04 LTS (Standard_B2as_v2 — 2 vCPU, 8 Go RAM)
Réseau : Virtual Network (VNET) avec Network Security Group (NSG)
Accès : SSH via clés asymétriques RSA

Stack Applicative (Docker)
Tous les services sont conteneurisés via Docker Compose.
🌐 Application (app/docker-compose.yml)
ServiceImagePortDescriptionalthea-webnginx:alpine (custom)80Serveur web frontendalthea-dbpostgres:155432Base de données patients
📊 Monitoring (docker-compose-monitoring.yml)
ServiceImagePortDescriptionprometheusprom/prometheus9090Collecte des métriquesnode-exporterprom/node-exporter9100Métriques système Linuxgrafanagrafana/grafana3000Visualisation & dashboardslokigrafana/loki3100Agrégation des logspromtailgrafana/promtail—Agent de collecte des logs

🚀 Installation
Prérequis

Ubuntu 24.04 LTS
Accès root (sudo)
Connexion internet

Déploiement en une commande
bashgit clone https://github.com/Mansa33/Sujet-Devops.git
cd Sujet-Devops
cp /path/to/install.sh .
sudo bash install.sh
Le script install.sh installe automatiquement Docker si absent, puis démarre les deux stacks.

🔐 Configuration
Variables d'environnement (app/.env)
envPOSTGRES_PASSWORD=Administrateur123*
POSTGRES_USER=althea_admin
DB_NAME=patient_db
Ports ouverts (NSG Azure)
RèglePortProtocoleSSH22TCPHTTP80TCPHTTPS443TCPGrafana3000TCPPrometheus9090TCPNode Exporter9100TCPLoki3100TCP

📡 Accès aux services
ServiceURL🌐 Application Webhttp://<IP>:80📊 Grafanahttp://<IP>:3000🔥 Prometheushttp://<IP>:9090📋 Loki (API)http://<IP>:3100/ready🖥️ Node Exporterhttp://<IP>:9100

Grafana — identifiants par défaut : admin / admin


📈 Dashboards Grafana
Node Exporter Full (ID: 1860)
Dashboard complet pour le monitoring système Linux :

CPU (usage, charge, fréquence)
RAM (utilisée, cache, swap)
Réseau (trafic par interface)
Disque (I/O, espace utilisé)
Processus & Systemd

Prometheus Stats
Métriques internes de Prometheus avec panel Loki intégré pour la visualisation des logs système en temps réel.
Configuration Loki dans Grafana

Connections → Data sources → Add data source → Loki
URL : http://loki:3100
Save & Test


🔒 Sécurité

Image Nginx construite sur Alpine Linux (< 100 Mo)
Exécution Nginx en utilisateur non-root (altheauser)
Healthcheck Docker sur le conteneur web
Accès SSH uniquement par clés asymétriques
Isolation réseau via bridge Docker dédié (althea-net)


📁 Structure du projet
Sujet-Devops/
├── app/
│   ├── docker-compose.yml        # Stack applicative
│   ├── .env                      # Variables d'environnement
│   └── web-custom/
│       ├── Dockerfile            # Image Nginx sécurisée
│       └── index.html            # Page web Althea
├── docker-compose-monitoring.yml # Stack monitoring
├── prometheus.yml                # Config scraping Prometheus
├── promtail-config.yml           # Config collecte logs Loki
└── README.md

🛑 Arrêt des services
bashbash stop.sh

🧰 Technologies utilisées
Docker Docker Compose Nginx PostgreSQL Prometheus Grafana Loki Promtail Node Exporter Azure Ubuntu 24.04
