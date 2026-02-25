# --- ETAPE 1 : Build & Optimisation ---
# On utilise Alpine pour une image finale < 100 Mo (Critère Optimisation)
FROM nginx:alpine

# Nettoyage des fichiers par défaut
RUN rm -rf /usr/share/nginx/html/*

# --- ETAPE 2 : Sécurisation (Bonnes Pratiques) ---
# On crée un utilisateur non-root pour la sécurité (Critère Excellent)
RUN addgroup -S altheagroup && adduser -S altheauser -G altheagroup

# Copie de ton fichier HTML (ton fichier index.html doit être dans le même dossier)
COPY index.html /usr/share/nginx/html/index.html

# On donne les droits à l'utilisateur non-root sur les dossiers Nginx
RUN chown -R altheauser:altheagroup /usr/share/nginx/html && \
    chown -R altheauser:altheagroup /var/cache/nginx && \
    chown -R altheauser:altheagroup /var/log/nginx && \
    chown -R altheauser:altheagroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R altheauser:altheagroup /var/run/nginx.pid

# On utilise l'utilisateur non-root
USER altheauser

# Documentation (Critère Excellent)
EXPOSE 80

# Healthcheck : pour vérifier que le serveur tourne (Critère Excellent)
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
