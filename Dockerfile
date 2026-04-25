ARG GUAC_VERSION
FROM guacamole/guacamole:${GUAC_VERSION}

USER root

# Install guacd + init system
RUN apt-get update && \
    apt-get install -y guacd dumb-init && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenID extension
COPY *.jar /opt/guacamole/extensions/

# Enable env config
ENV ENABLE_ENVIRONMENT_PROPERTIES=true
ENV EXTENSION_PRIORITY="*,openid"

# Use proper init
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# IMPORTANT: preserve upstream startup behavior
CMD ["/bin/bash", "-c", "/usr/sbin/guacd -f & /opt/guacamole/bin/start.sh"]