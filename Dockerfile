ARG GUAC_VERSION=1.6.0
FROM guacamole/guacamole:${GUAC_VERSION}

ARG GUAC_VERSION

USER root

# Install guacd + proper init
RUN apt-get update && \
    apt-get install -y guacd dumb-init curl ca-certificates tar && \
    rm -rf /var/lib/apt/lists/*

# Download OpenID + JDBC auth extensions for the selected Guacamole version
RUN set -eux; \
    curl -fsSL -o /tmp/sso.tar.gz "https://downloads.apache.org/guacamole/${GUAC_VERSION}/binary/guacamole-auth-sso-${GUAC_VERSION}.tar.gz"; \
    curl -fsSL -o /tmp/jdbc.tar.gz "https://downloads.apache.org/guacamole/${GUAC_VERSION}/binary/guacamole-auth-jdbc-${GUAC_VERSION}.tar.gz"; \
    tar -xzf /tmp/sso.tar.gz -C /tmp; \
    tar -xzf /tmp/jdbc.tar.gz -C /tmp; \
    cp /tmp/guacamole-auth-sso-${GUAC_VERSION}/openid/*.jar /opt/guacamole/extensions/; \
    cp /tmp/guacamole-auth-jdbc-${GUAC_VERSION}/mysql/*.jar /opt/guacamole/extensions/; \
    cp /tmp/guacamole-auth-jdbc-${GUAC_VERSION}/postgresql/*.jar /opt/guacamole/extensions/; \
    cp /tmp/guacamole-auth-jdbc-${GUAC_VERSION}/sqlserver/*.jar /opt/guacamole/extensions/; \
    rm -rf /tmp/sso.tar.gz /tmp/jdbc.tar.gz \
           /tmp/guacamole-auth-sso-${GUAC_VERSION} \
           /tmp/guacamole-auth-jdbc-${GUAC_VERSION}

# Enable env config
ENV ENABLE_ENVIRONMENT_PROPERTIES=true
ENV EXTENSION_PRIORITY="openid,*"

# Use init for proper signal handling
ENTRYPOINT ["/usr/bin/dumb-init", "--"]

# Run guacd, then exec the original entrypoint
CMD ["/bin/bash", "-c", "/usr/sbin/guacd -f & exec /opt/guacamole/bin/entrypoint.sh"]