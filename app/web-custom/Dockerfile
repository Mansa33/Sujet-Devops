# --- ETAPE 1 : Build & Optimisation ---
# Utilisation d'Alpine pour garantir une image < 100 Mo
FROM nginx:alpine

# Nettoyage des fichiers par defaut de Nginx
RUN rm -rf /usr/share/nginx/html/*

# --- ETAPE 2 : Securisation (Bonnes Pratiques) ---
# Creation d'un utilisateur non-root pour isoler l'execution
RUN addgroup -S altheagroup && adduser -S altheauser -G altheagroup

# Copie du code source de l'application
COPY index.html /usr/share/nginx/html/index.html

# Configuration Nginx avec stub_status pour les metriques Prometheus
RUN printf 'server {\n\
    listen 80;\n\
    location / {\n\
        root /usr/share/nginx/html;\n\
        index index.html;\n\
    }\n\
    location /stub_status {\n\
        stub_status on;\n\
        allow all;\n\
    }\n\
}\n' > /etc/nginx/conf.d/default.conf

# Attribution des droits stricts a l'utilisateur non-root
RUN chown -R altheauser:altheagroup /usr/share/nginx/html && \
    chown -R altheauser:altheagroup /var/cache/nginx && \
    chown -R altheauser:altheagroup /var/log/nginx && \
    chown -R altheauser:altheagroup /etc/nginx/conf.d && \
    touch /var/run/nginx.pid && \
    chown -R altheauser:altheagroup /var/run/nginx.pid

# Bascule sur l'utilisateur securise
USER altheauser

# --- ETAPE 3 : Documentation & Supervision ---
EXPOSE 80

# Verification de l'etat de sante du conteneur pour l'orchestrateur
HEALTHCHECK --interval=30s --timeout=3s \
  CMD curl -f http://localhost/ || exit 1

CMD ["nginx", "-g", "daemon off;"]
