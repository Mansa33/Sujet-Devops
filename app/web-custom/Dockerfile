# --- ETAPE 1 : Build & Optimisation ---
# Utilisation d'Alpine pour garantir une image < 100 Mo
FROM nginx:alpine

# Nettoyage des fichiers par défaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# --- ETAPE 2 : Sécurisation (Bonnes Pratiques) ---
# Création d'un utilisateur non-root pour isoler l'exécution
RUN addgroup -S altheagroup && adduser -S altheauser -G altheagroup

# Copie du code source de l'application
COPY index.html /usr/share/nginx/html/index.html

# Attribution des droits stricts à l'utilisateur non-root
RUN chown -R altheauser:altheagroup /usr/share/nginx/html && \
    chown -R altheauser:altheagroup /var/cache/nginx && \
    chown -R altheauser:altheagroup /var/log/nginx && \
    chown -R altheauser:altheagroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R altheauser:altheagroup /var/run/nginx.pid

# Bascule sur l'utilisateur sécurisé
USER altheauser

# --- ETAPE 3 : Documentation & Supervision ---
EXPOSE 80

# Vérification de l'état de santé du conteneur pour l'orchestrateur
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
