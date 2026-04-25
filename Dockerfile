ARG GUAC_VERSION
FROM guacamole/guacamole:${GUAC_VERSION}

# Become root to install guacd
USER root

# Install guacd inside container
RUN apt-get update && \
    apt-get install -y guacd && \
    rm -rf /var/lib/apt/lists/*

# Copy OpenID extension
COPY *.jar /opt/guacamole/extensions/

# Enable env-based config + OpenID
ENV ENABLE_ENVIRONMENT_PROPERTIES=true
ENV EXTENSION_PRIORITY="*,openid"

# Start guacd + guacamole
CMD /usr/sbin/guacd -f & catalina.sh run