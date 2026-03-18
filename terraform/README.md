# Infrastructure as Code — Terraform

Ce dossier contient les fichiers Terraform pour deployer l'infrastructure Azure de la plateforme Althea de maniere 100% reproductible.

## Structure

| Fichier | Description |
|---|---|
| `main.tf` | Ressources Azure principales (VM, reseau, NSG, IP) |
| `variables.tf` | Declaration de toutes les variables |
| `terraform.tfvars` | Valeurs des variables (subscription, region, etc.) |
| `outputs.tf` | Valeurs retournees apres le deploiement (IP publique, SSH) |
| `cloud-init.sh` | Script d'initialisation de la VM au premier demarrage |

## Ressources deployees

- Resource Group
- Virtual Network + Subnet (10.1.0.0/16)
- Network Security Group (ports 22, 80, 3000, 9090 ouverts)
- IP publique statique
- Interface reseau
- VM Ubuntu 22.04 LTS (Standard_B2als_v2)

## Services installes automatiquement par cloud-init

Au premier demarrage la VM installe et demarre automatiquement :
- Docker + Docker Compose
- Nginx (app web Althea)
- PostgreSQL 15
- Prometheus
- Grafana
- Loki
- Promtail
- Node Exporter

## Utilisation

### Prerequis

- Terraform >= 1.0
- Azure CLI installe et connecte (`az login`)
- Cle SSH generee

### Deploiement
```bash
cd terraform
terraform init
terraform plan
terraform apply
```

### Verification

Apres le deploiement, attendre 5-7 minutes puis :
```bash
ssh azureadmin@<IP_PUBLIQUE>
cat ~/setup.log      # Doit afficher "Setup complete at..."
docker ps            # Doit afficher 7 containers
```

### Destruction
```bash
terraform destroy
```

## Variables requises

| Variable | Description |
|---|---|
| `subscription_id` | ID de la subscription Azure |
| `admin_password` | Mot de passe admin de la VM |
| `ssh_public_key` | Cle SSH publique pour l'acces |
