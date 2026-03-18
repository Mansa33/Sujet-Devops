# Althea DevOps — Infrastructure de Monitoring

Projet DevOps déployé sur Microsoft Azure (Switzerland North) dans le cadre d'un hébergement conforme HDS (Hébergement de Données de Santé).

---

## Architecture

### Infrastructure Cloud

- **Provider** : Microsoft Azure — Région Switzerland North
- **IP Publique** : `74.242.170.50`
- **VM** : Ubuntu 24.04 LTS (Standard_B2as_v2 — 2 vCPU, 8 Go RAM)
- **Réseau** : Virtual Network (VNET) avec Network Security Group (NSG)
- **Accès** : SSH via clés asymétriques RSA

### Stack Applicative (Docker)

Tous les services sont conteneurisés via Docker Compose.

#### Application (`app/docker-compose.yml`)

| Service | Image | Port | Description |
|---|---|---|---|
| `althea-web` | `nginx:alpine` (custom) | 80 | Serveur web frontend |
| `althea-db` | `postgres:15` | 5432 | Base de données patients |

#### Monitoring (`docker-compose-monitoring.yml`)

| Service | Image | Port | Description |
|---|---|---|---|
| `prometheus` | `prom/prometheus` | 9090 | Collecte des métriques |
| `node-exporter` | `prom/node-exporter` | 9100 | Métriques système Linux |
| `grafana` | `grafana/grafana` | 3000 | Visualisation & dashboards |
| `loki` | `grafana/loki` | 3100 | Agrégation des logs |
| `promtail` | `grafana/promtail` | — | Agent de collecte des logs |

---

## Installation

### Prérequis

- Ubuntu 24.04 LTS
- Accès root (`sudo`)
- Connexion internet

## Configuration

### Variables d'environnement (`app/.env`)

```env
POSTGRES_PASSWORD=Administrateur123*
POSTGRES_USER=althea_admin
DB_NAME=patient_db
```

### Ouverture des ports — Network Security Group Azure

Les règles de sécurité réseau ont été configurées manuellement dans le NSG `myVM-nsg` via le portail Azure (Portail Azure > myVM-nsg > Inbound security rules > Add).

| Nom de la règle | Priorité | Port | Protocole | Source | Action |
|---|---|---|---|---|---|
| SSH | 300 | 22 | TCP | Any | Allow |
| HTTP | 340 | 80 | TCP | Any | Allow |
| HTTPS | 320 | 443 | TCP | Any | Allow |
| Grafana | 350 | 3000 | TCP | Any | Allow |
| Prometheus | 360 | 9090 | TCP | Any | Allow |
| Monitoring | 370 | 9100, 3100 | TCP | Any | Allow |

Pour ajouter une règle dans le portail Azure :
1. Aller dans **myVM-nsg** > **Inbound security rules** > **+ Add**
2. Renseigner le port de destination, protocole TCP, action Allow
3. Attribuer une priorité unique (nombre plus bas = priorité plus haute)
4. Sauvegarder

---

## Accès aux services

| Service | URL complète |
|---|---|
| Application Web | http://74.242.170.50 |
| Grafana | http://74.242.170.50:3000 |
| Prometheus | http://74.242.170.50:9090 |
| Loki (API health) | http://74.242.170.50:3100/ready |
| Node Exporter | http://74.242.170.50:9100 |

Grafana — identifiants par défaut : `admin` / `admin`

---

## Dashboards Grafana

### Node Exporter Full (ID: 1860)

Dashboard complet pour le monitoring système Linux importé depuis grafana.com.
Il affiche en temps réel :

- CPU (usage par mode, charge système, fréquence de scaling)
- RAM (utilisée, cache, swap, buffers)
- Réseau (trafic par interface, erreurs, drops)
- Disque (I/O, throughput, espace utilisé par partition)
- Processus, Systemd, entropie

Pour l'importer : **Dashboards > Import > ID 1860 > Load > sélectionner Prometheus > Import**

### Prometheus Stats

Dashboard des métriques internes de Prometheus avec un panel Loki ajouté manuellement pour visualiser les logs système en temps réel.

### Configuration des datasources dans Grafana

**Prometheus :**
1. Connections > Data sources > Add data source > Prometheus
2. URL : `http://prometheus:9090`
3. Save & Test

**Loki :**
1. Connections > Data sources > Add data source > Loki
2. URL : `http://loki:3100`
3. Save & Test

---

## Securite

- Image Nginx construite sur Alpine Linux (taille inferieure a 100 Mo)
- Execution Nginx en utilisateur non-root (`altheauser`)
- Healthcheck Docker configure sur le conteneur web (intervalle 30s, timeout 3s)
- Acces SSH uniquement par cles asymetriques RSA
- Isolation reseau via bridge Docker dedie (`althea-net`)
- Aucun port de base de donnees expose publiquement (PostgreSQL accessible uniquement en interne)

---

## Structure du projet

```
Sujet-Devops/
├── app/
│   ├── docker-compose.yml        # Stack applicative
│   ├── .env                      # Variables d'environnement
│   └── web-custom/
│       ├── Dockerfile            # Image Nginx securisee
│       └── index.html            # Page web Althea
├── docker-compose-monitoring.yml # Stack monitoring
├── prometheus.yml                # Configuration scraping Prometheus
├── promtail-config.yml           # Configuration collecte logs Loki
└── README.md
```

---
## Automatisation CI/CD (GitHub Actions)

Un pipeline d'intégration et de déploiement continu (CI/CD) est configuré via GitHub Actions (`.github/workflows/ci-cd.yml`) pour automatiser les mises en production tout en respectant les normes de sécurité de l'infrastructure (contexte HDS).

### Fonctionnement du Pipeline

1. **Déclenchement** : Le pipeline s'exécute automatiquement à chaque `push` sur la branche `main`.
2. **Build & Push (ACR)** : 
   - L'image Docker front-end (`althea-web`) est construite et doublement taguée (tag `latest` et tag avec le SHA du commit pour une traçabilité parfaite).
   - Elle est ensuite poussée vers notre registre privé **Azure Container Registry (ACR)**.
3. **Déploiement (SSH)** :
   - Une fois l'image stockée, le pipeline se connecte à la VM Azure via SSH.
   - Le code source est mis à jour (`git pull`) et les conteneurs applicatifs sont recréés dynamiquement via Docker Compose.

### Sécurité du déploiement
- **Gestion des secrets** : Aucune donnée sensible n'est hardcodée. Les identifiants du registre ACR et les clés SSH de la VM sont stockés de manière chiffrée dans les **GitHub Secrets**.
- **Registre Privé** : L'utilisation d'ACR garantit que nos images Docker (contenant potentiellement des configurations liées au domaine de la santé) ne sont pas exposées publiquement sur le Docker Hub.
## Arret des services

## Technologies utilisees

Docker — Docker Compose — Nginx — PostgreSQL — Prometheus — Grafana — Loki — Promtail — Node Exporter — Microsoft Azure — Ubuntu 24.04 LTS
