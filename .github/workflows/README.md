# CI/CD Pipeline — GitHub Actions

Ce dossier contient le pipeline CI/CD qui automatise le build, le push et le deploiement de l'image Docker a chaque push sur la branche `main`.

## Fichier

| Fichier | Description |
|---|---|
| `ci-cd.yml` | Pipeline complet build + push ACR + deploy SSH |

## Fonctionnement

### Declenchement automatique

Le pipeline se declenche automatiquement sur chaque `push` ou `merge` vers la branche `main`.

### Etapes du pipeline

**Job 1 — Build and Push Docker Image**
1. Checkout du code source
2. Authentification au registre Azure Container Registry (ACR) via les secrets GitHub
3. Build de l'image Nginx avec deux tags : `latest` et le SHA du commit
4. Push des deux tags vers ACR

**Job 2 — Deploy to Azure VM**
1. Connexion SSH a la VM Azure
2. `git reset --hard origin/main` pour synchroniser le code
3. Arret et redemarrage des containers avec la nouvelle image
4. Confirmation du deploiement

## Secrets GitHub requis

| Secret | Description |
|---|---|
| `ACR_LOGIN_SERVER` | URL du registre ACR (ex: altheadevops.azurecr.io) |
| `ACR_USERNAME` | Nom d'utilisateur ACR |
| `ACR_PASSWORD` | Mot de passe ACR |
| `VM_HOST` | IP publique de la VM Azure |
| `VM_USERNAME` | Utilisateur SSH (azureadmin) |
| `VM_SSH_KEY` | Cle privee SSH pour la connexion |

## Configuration des secrets

1. Aller dans **Settings** du repo GitHub
2. **Secrets and variables** > **Actions**
3. **New repository secret** pour chaque secret

## Registre ACR

Les images buildees sont stockees dans Azure Container Registry :
- `altheadevops.azurecr.io/althea-web:latest`
- `altheadevops.azurecr.io/althea-web:<SHA_COMMIT>`
