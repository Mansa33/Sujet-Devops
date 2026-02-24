Ce dépôt contient l'infrastructure et la configuration logicielle pour la plateforme SaaS **Althea Systems**, spécialisée dans la gestion de données de santé.

## 🚀 Architecture Déployée
L'infrastructure est hébergée sur **Microsoft Azure** (Région : France Central) pour garantir la conformité HDS (Hébergement de Données de Santé).

- **Serveur** : VM Debian 12 (Standard_B2as_v2, 8 Go RAM).
- **Réseau** : Virtual Network (VNET) segmenté avec filtrage par Groupe de Sécurité Réseau (NSG).
- **Sécurité** : Accès administration via clés SSH asymétriques (RSA 2048).

## 🐳 Stack Applicative (Docker)
L'application est conteneurisée pour garantir l'isolation des services et la portabilité :

1. **Web Server** : Nginx (Latest) - Point d'entrée utilisateur (Port 80).
2. **Database** : PostgreSQL 15 - Stockage sécurisé des données patients.
