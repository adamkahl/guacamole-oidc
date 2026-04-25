ARG GUAC_VERSION
FROM guacamole/guacamole:${GUAC_VERSION}

USER root

# Install guacd + dumb-init for proper process handling
RUN apt-get update && \
    apt-get install -y guacd dumb-init && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenID extension JAR (downloaded in your GitHub Action)
COPY *.jar /opt/guacamole/extensions/

# Enable env-based configuration + OpenID
ENV ENABLE_ENVIRONMENT_PROPERTIES=true
ENV EXTENSION_PRIORITY="*,openid"

# Use dumb-init so signals/cleanup work properly
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Start guacd AND preserve the original Guacamole startup
CMD ["/bin/bash", "-c", "/usr/sbin/guacd -f & exec /docker-entrypoint.sh"]