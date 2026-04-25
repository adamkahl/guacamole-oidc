ARG GUAC_VERSION
FROM guacamole/guacamole:${GUAC_VERSION}

USER root

# Install guacd + proper init
RUN apt-get update && \
    apt-get install -y guacd dumb-init && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenID extension
COPY *.jar /opt/guacamole/extensions/

# Enable env config
ENV ENABLE_ENVIRONMENT_PROPERTIES=true
ENV EXTENSION_PRIORITY="*,openid"

# Use init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run guacd, then exec the original entrypoint
CMD ["/bin/bash", "-c", "/usr/sbin/guacd -f & exec /opt/guacamole/bin/entrypoint.sh"]